# Girls Band Tabi — 전체 페이지 명세서

> 작성일: 2026-03-19
> 기준 브랜치: `dev`
> 아키텍처: Flutter Clean Architecture (Riverpod 상태관리, GoRouter 라우팅)
> Base URL: `/api/v1`

---

## 목차

1. [앱 구조 개요](#1-앱-구조-개요)
2. [인증 (Auth)](#2-인증-auth)
3. [홈 (Home)](#3-홈-home)
4. [탐방 (Explore)](#4-탐방-explore)
   - 4-1. 장소 지도 (Places Map)
   - 4-2. 라이브 이벤트 목록 (Live Events)
   - 4-3. 방문 기록 (Visit History)
   - 4-4. 성지순례 도감 (Zukan)
5. [정보 (Info)](#5-정보-info)
   - 5-1. 소식 탭 (News)
   - 5-2. 유닛 탭 (Units)
   - 5-3. 성우 탭 (Voice Actors)
   - 5-4. 악곡 탭 (Music)
   - 5-5. 더보기 탭
6. [커뮤니티 (Community / Feed)](#6-커뮤니티-community--feed)
7. [마이 (My)](#7-마이-my)
8. [설정 (Settings)](#8-설정-settings)
9. [공통/모달 페이지](#9-공통모달-페이지)
10. [관리자 운영 센터 (Admin Ops)](#10-관리자-운영-센터-admin-ops)
11. [전체 API 엔드포인트 색인](#11-전체-api-엔드포인트-색인)

---

## 1. 앱 구조 개요

### 하단 네비게이션 (StatefulShellRoute.indexedStack)

| 탭 인덱스 | 라우트 이름 | 경로 | 페이지 |
|---------|-----------|------|------|
| 0 | `home` | `/home` | 홈 페이지 |
| 1 | `explore` | `/explore` | 탐방 페이지 (지도/라이브/방문기록/도감) |
| 2 | `information` | `/information` | 정보 페이지 (소식/유닛/성우/악곡/더보기) |
| 3 | `mypage` | `/mypage` | 마이 페이지 |
| 4 | `community` | `/community` | 커뮤니티 게시판 |

### 주요 라우트 상수 (`AppRoutes`)

| 상수 | 경로 |
|-----|------|
| `login` | `/login` |
| `register` | `/register` |
| `oauthCallback` | `/auth/callback` |
| `settings` | `/settings` |
| `profileEdit` | `/settings/profile` |
| `notificationSettings` | `/settings/notifications` |
| `accountTools` | `/settings/account-tools` |
| `communitySettings` | `/community-settings` |
| `privacyRights` | `/settings/privacy-rights` |
| `consentHistory` | `/settings/consents` |
| `adminOps` | `/settings/admin` |
| `bannerPicker` | `/banner-picker` |
| `titleCatalog` | `/mypage/titles` |
| `fanLevel` | `/mypage/fan-level` |
| `calendar` | `/calendar` |
| `zukan` | `/zukan` |
| `zukanDetail` | `/zukan/:collectionId` |
| `cheerGuides` | `/cheer-guides` |
| `cheerGuideDetail` | `/cheer-guides/:guideId` |
| `quotes` | `/quotes` |
| `favorites` | `/favorites` |
| `visitHistory` | `/visits` |
| `visitDetail` | `/visits/:visitId` |
| `visitStats` | `/visits/stats` |
| `notifications` | `/notifications` |
| `search` | `/search` |
| `placeDetail` | `/places/:placeId` |
| `liveEventDetail` | `/live/:eventId` |
| `postDetail` | `/posts/:postId` |
| `postCreate` | `/posts/create` |
| `postEdit` | `/posts/:postId/edit` |
| `postBookmarks` | `/bookmarks` |
| `userProfile` | `/users/:userId` |
| `userConnections` | `/users/:userId/connections` |
| `newsDetail` | `/news/:newsId` |
| `unitDetail` | `/units/:unitId` |
| `memberDetail` | `/units/:unitId/members/:memberId` |
| `voiceActorDetail` | `/voice-actors/:voiceActorId` |
| `songDetail` | `/music/songs/:songId` |

---

## 2. 인증 (Auth)

### 2-1. 로그인 페이지 (`LoginPage`)

- **경로**: `/login`
- **라우트 상수**: `AppRoutes.login`

**기능**
- 이메일 + 비밀번호 폼 로그인
- OAuth 소셜 로그인 버튼 (Google 등)
- 회원가입 링크
- 로그인 없이 둘러보기

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `POST` | `/auth/login` | 이메일/비밀번호 로그인 |

**상태 관리**: `authControllerProvider`, `authStateProvider`

**네비게이션**
- 로그인 성공 → `/home`
- 회원가입 → `/register`

---

### 2-2. 회원가입 페이지 (`RegisterPage`)

- **경로**: `/register`
- **라우트 상수**: `AppRoutes.register`

**기능**
- 이메일 + 비밀번호 + 닉네임 입력
- 비밀번호 실시간 강도 검증 (대/소/숫자/특수문자)
- 필수 동의 체크박스:
  - 이용약관 동의
  - 개인정보 처리방침 동의
  - 위치정보 이용약관 동의
  - 만 14세 이상 확인

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `POST` | `/auth/register` | 신규 계정 생성 |

**상태 관리**: `authControllerProvider`

---

### 2-3. OAuth 콜백 페이지 (`OAuthCallbackPage`)

- **경로**: `/auth/callback`
- **라우트 상수**: `AppRoutes.oauthCallback`
- **쿼리 파라미터**: `provider`, `code`, `state`

**기능**
- OAuth 인가 코드 수신
- State(CSRF) 검증
- 백엔드 토큰 교환

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/auth/callback?code=...&state=...` | OAuth 코드 교환 |

**상태 관리**: `authOAuthServiceProvider`, `authControllerProvider`

---

## 3. 홈 (Home)

### 홈 페이지 (`HomePage`)

- **경로**: `/home` (탭 0)
- **라우트 상수**: `AppRoutes.home`

**기능**
- 인사말 헤더 (사용자 이름 + 프로필 배너 이미지)
- 홈 배너 슬라이드 캐러셀
- 피처 라이브 이벤트 표시
- 추천 장소 캐러셀
- 트렌딩 라이브 이벤트 캐러셀
- 최신 소식 컴팩트 목록 (상위 5개)
- 프로젝트 선택 게이트
- 스폰서 광고 슬롯
- 당겨서 새로고침

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/home/summary` | 홈 요약 (추천 장소, 트렌딩 라이브, 최신 뉴스) |
| `GET` | `/home/summary/by-project` | 프로젝트별 홈 요약 |
| `GET` | `/home/banners` | 홈 배너 슬라이드 목록 |
| `GET` | `/ads/decision` | 광고 슬롯 결정 조회 |

**상태 관리**: `homeControllerProvider`, `activeBannerProvider`, `projectSelectionControllerProvider`, `userProfileControllerProvider`

**네비게이션**
- 검색 아이콘 → `/search`
- 알림 아이콘 → `/notifications`
- 배너 커스터마이징 → `/banner-picker`
- 추천 장소 카드 → `/places/:placeId`
- 트렌딩 라이브 카드 → `/live/:eventId`
- 최신 소식 카드 → `/news/:newsId`
- 탐방 바로가기 → `/explore`

---

## 4. 탐방 (Explore)

### 탐방 허브 페이지 (`ExplorePage`)

- **경로**: `/explore` (탭 1)
- **쿼리 파라미터**: `initialTabIndex` (선택)
- **4개 서브탭**: 지도 / 라이브 / 방문기록 / 성지도감

---

### 4-1. 장소 지도 (`PlacesMapPage`)

**기능**
- iOS: Apple Maps, Android: Google Maps 플랫폼 분기
- 장소 마커 표시 (유형별 아이콘/색상)
- 지도 범위 내 장소 동적 조회
- 지역 필터 (도도부현/구별)
- 유닛/밴드별 마커 필터
- 현재 위치 인근 장소 조회
- 마커 탭 → 장소 상세 미리보기 카드
- 미리보기 카드 탭 → 장소 상세 페이지

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/places` | 장소 목록 조회 |
| `GET` | `/projects/{projectId}/places/within-bounds` | 지도 범위 내 장소 조회 |
| `GET` | `/projects/{projectId}/places/nearby` | 현재 위치 인근 장소 |
| `GET` | `/projects/{projectId}/places/regions/available` | 지역 필터 옵션 |
| `GET` | `/projects/{projectId}/places/regions/filter` | 지역별 필터링 장소 |
| `GET` | `/projects/{projectId}/places/regions/map-bounds` | 지역 지도 경계 |

**상태 관리**: `placesListControllerProvider`, `placeDetailControllerProvider`

---

### 4-2. 라이브 이벤트 목록 (`LiveEventsPage`)

**기능**
- Upcoming / Done 2개 탭
- 프로젝트별 필터
- 유닛/밴드별 다중 선택 필터
- 연도별 필터
- 라이브 이벤트 카드 목록 (날짜, 장소, 포스터)
- 무한 스크롤 페이지네이션
- 방문 기록 탭 (참석한 이벤트만)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/live-events` | 라이브 이벤트 목록 |
| `GET` | `/projects/{projectId}/live-events/attendances` | 라이브 방문 기록 |

**상태 관리**: `liveEventsListControllerProvider`, `selectedLiveBandIdsProvider`, `selectedLiveEventYearProvider`, `liveAttendanceHistoryControllerProvider`

---

### 4-3. 라이브 이벤트 상세 (`LiveEventDetailPage`)

- **경로**: `/live/:eventId`
- **라우트 상수**: `AppRoutes.liveEventDetail`

**기능**
- 이벤트 상세 정보 (일시, 장소, 공연장, 포스터)
- 참석 여부 토글 버튼
- 세트리스트 조회
- 즐겨찾기 추가/해제
- 공유 기능
- GPS 방문 검증 상태 표시
- 티켓 구매 외부 링크

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/live-events/{eventId}` | 이벤트 상세 조회 |
| `GET` | `/projects/{projectId}/live-events/{eventId}/attendance` | 참석 상태 조회 |
| `PUT` | `/projects/{projectId}/live-events/{eventId}/attendance` | 참석 상태 토글 |
| `GET` | `/projects/{projectId}/live-events/{eventId}/setlist` | 세트리스트 조회 |
| `POST` | `/users/me/favorites` | 즐겨찾기 추가 |
| `DELETE` | `/users/me/favorites` | 즐겨찾기 해제 |

**상태 관리**: `liveEventDetailControllerProvider`, `liveAttendanceControllerProvider`, `liveEventSetlistProvider`, `favoritesControllerProvider`

---

### 4-4. 라이브 방문 기록 (`LiveAttendanceHistoryPage`)

- **경로**: `/visits?tab=live`

**기능**
- 프로젝트별 라이브 참석 기록
- 검증 완료/미검증 상태 뱃지
- 무한 스크롤
- 당겨서 새로고침

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/live-events/attendances?page={n}&size={n}` | 라이브 방문 기록 조회 |

**상태 관리**: `liveAttendanceHistoryControllerProvider`, `projectsControllerProvider`

---

### 4-5. 방문 기록 (`VisitHistoryPage`)

- **경로**: `/visits`
- **라우트 상수**: `AppRoutes.visitHistory`
- **탭**: 장소(places) / 라이브(live)

**기능**
- 타임라인 형식 방문 기록
- 프로젝트별 그룹화
- 월별 그룹화
- 당겨서 새로고침

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me/visits` | 장소 방문 기록 조회 |

**상태 관리**: `userVisitsControllerProvider`, `visitAllProjectsPlacesMapProvider`

---

### 4-6. 방문 상세 (`VisitDetailPage`)

- **경로**: `/visits/:visitId`
- **라우트 상수**: `AppRoutes.visitDetail`
- **쿼리 파라미터**: `placeId`, `visitedAt`, `latitude`, `longitude`

**기능**
- 히어로 이미지 앱바
- 방문 일시 카드
- GPS 인증 여부 뱃지
- 장소 정보 섹션
- 인증 좌표 미니 지도
- 방문 통계 (총 방문 횟수, 첫 방문일, 최근 방문일)
- 장소 상세 보기 버튼

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me/visits/{visitId}` | 방문 상세 조회 |
| `GET` | `/users/me/visits/summary` | 장소별 방문 요약 통계 |

**상태 관리**: `visitDetailProvider`, `visitSummaryProvider`, `visitPlacesMapProvider`

---

### 4-7. 방문 통계 (`VisitStatsPage`)

- **경로**: `/visits/stats`
- **라우트 상수**: `AppRoutes.visitStats`

**기능**
- 랭킹 배너 (내 순위, 상위 %)
- 통계 카드 그리드 (총 방문, 방문 장소 수, 첫 방문일, 최근 방문일)
- 자주 방문한 장소 Top 5 (랭킹 뱃지)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me/visits` | 방문 기록 전체 조회 |
| `GET` | `/projects/{projectId}/rankings/users` | 사용자 방문 랭킹 |

**상태 관리**: `userVisitsControllerProvider`, `userRankingProvider`, `visitPlacesMapProvider`

---

### 4-8. 장소 상세 (`PlaceDetailPage`)

- **경로**: `/places/:placeId`
- **라우트 상수**: `AppRoutes.placeDetail`

**기능**
- 히어로 이미지 갤러리 (슬라이드)
- 장소 기본 정보 (이름, 주소, 분류, 설명)
- 관련 밴드/유닛 태그
- 위치 가이드 목록
- 방문 후기(댓글) 목록 및 작성
- GPS 검증 방문 인증 버튼 (하단 고정)
- 즐겨찾기 추가/해제
- 지도 앱으로 길찾기 (Apple Maps / Google Maps)
- 기여자 크레딧

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/places/{placeId}` | 장소 상세 조회 |
| `GET` | `/places/{placeId}/guides` | 장소 가이드 목록 |
| `GET` | `/places/{placeId}/guides/high-priority` | 우선순위 높은 가이드 |
| `GET` | `/places/{placeId}/comments` | 방문 후기 목록 |
| `POST` | `/places/{placeId}/comments` | 방문 후기 작성 |
| `DELETE` | `/places/{placeId}/comments/{commentId}` | 후기 삭제 |
| `GET` | `/projects/{projectId}/rankings/most-visited` | 방문 많은 장소 랭킹 |
| `GET` | `/projects/{projectId}/rankings/most-liked` | 즐겨찾기 많은 장소 랭킹 |
| `POST` | `/users/me/favorites` | 즐겨찾기 추가 |
| `DELETE` | `/users/me/favorites` | 즐겨찾기 해제 |
| `GET` | `/{entityType}/{entityId}/contributors` | 기여자 조회 |
| `POST` | `/projects/{projectId}/places/{placeId}/verification` | GPS 장소 인증 |

**상태 관리**: `placeDetailControllerProvider`, `placeGuidesControllerProvider`, `placeCommentsControllerProvider`, `favoritesControllerProvider`

---

### 4-9. 방문 후기 작성 시트 (`PlaceReviewSheet`)

- **형식**: 모달 바텀시트 (PlaceDetailPage에서 호출)

**기능**
- 후기 텍스트 입력 (최소 10자)
- 사진 최대 5장 업로드 (WebP 자동 변환)
- 업로드 진행률 표시

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `POST` | `/uploads` | 이미지 업로드 (multipart/form-data) |
| `POST` | `/uploads/{uploadId}/confirm` | 업로드 완료 확인 |
| `POST` | `/places/{placeId}/comments` | 후기 작성 |

**상태 관리**: `uploadsControllerProvider`, `placesRepositoryProvider`

---

### 4-10. 성지순례 도감 목록 (`ZukanPage`)

- **경로**: `/zukan`
- **라우트 상수**: `AppRoutes.zukan`

**기능**
- 도감 컬렉션 목록 (그리드)
- 컬렉션별 방문 진행률 바
- 완료 여부 뱃지
- 컬렉션 상세로 이동

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/zukan/collections?projectId={projectId}` | 도감 컬렉션 목록 |

**상태 관리**: `zukanCollectionsProvider`, `selectedProjectKeyProvider`

---

### 4-11. 도감 컬렉션 상세 (`ZukanDetailPage`)

- **경로**: `/zukan/:collectionId`
- **라우트 상수**: `AppRoutes.zukanDetail`

**기능**
- 컬렉션 상세 정보 (제목, 설명, 완료 보상)
- 스탬프 그리드 3열 (방문 완료 / 잠금)
- 진행률 바
- 스탬프 탭 → 장소 상세 페이지

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/zukan/collections/{collectionId}` | 도감 컬렉션 상세 |

**상태 관리**: `zukanCollectionDetailProvider`

---

## 5. 정보 (Info)

### 정보 허브 페이지 (`InfoPage`)

- **경로**: `/information` (탭 2)
- **5개 탭**: 소식 / 유닛 / 성우 / 악곡 / 더보기

---

### 5-1. 소식 탭 (News)

**기능**
- 히어로 뉴스 카드 (최상단)
- 컴팩트 뉴스 리스트
- 무한 스크롤 페이지네이션

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/news` | 뉴스 목록 (페이지네이션) |

---

### 5-2. 뉴스 상세 (`NewsDetailPage`)

- **경로**: `/news/:newsId`
- **라우트 상수**: `AppRoutes.newsDetail`

**기능**
- 뉴스 제목, 날짜, 썸네일
- 본문 텍스트 (SelectableText)
- 북마크/공유 (예정)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/news/{newsId}` | 뉴스 상세 조회 |

---

### 5-3. 유닛 탭 (Units)

**기능**
- 프로젝트별 유닛 아코디언 목록
- 유닛 확장 시 멤버 카드 표시
- 유닛 상세 / 멤버 상세로 이동

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectKey}/units` | 유닛 목록 |
| `GET` | `/projects/{projectId}/units/{unitId}/members` | 유닛 멤버 목록 |

---

### 5-4. 유닛 상세 (`UnitDetailPage`)

- **경로**: `/units/:unitId?projectId={projectId}`
- **라우트 상수**: `AppRoutes.unitDetail`

**기능**
- 유닛 히어로 헤더 (팔레트 색상 그라데이션)
- 유닛 코드/상태 뱃지
- 유닛 설명
- 멤버 로스터 (order → 이름순 정렬)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/units/{unitId}` | 유닛 상세 |
| `GET` | `/projects/{projectId}/units/{unitId}/members` | 유닛 멤버 목록 |

---

### 5-5. 멤버(캐릭터) 상세 (`MemberDetailPage`)

- **경로**: `/units/:unitId/members/:memberId?projectId={projectId}`
- **라우트 상수**: `AppRoutes.memberDetail`

**기능**
- 캐릭터 아바타, 이름, CV 표시
- 유닛 뱃지, 담당 악기, 역할 태그
- 생일 카운트다운
- 프로필 테이블 (생일, 악기, 역할)
- 담당 성우 섹션

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/units/{unitId}/members/{memberId}` | 멤버 상세 |

---

### 5-6. 성우 탭 (Voice Actors)

**기능**
- 성우 디렉토리 목록
- 성우 상세로 이동

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectKey}/voice-actors` | 성우 목록 |

---

### 5-7. 성우 상세 (`VoiceActorDetailPage`)

- **경로**: `/voice-actors/:voiceActorId?projectId={projectId}`
- **라우트 상수**: `AppRoutes.voiceActorDetail`
- **2개 탭**: 담당 캐릭터 / 크레딧

**기능**
- 담당 캐릭터 목록
- 전체 작품 크레딧 목록

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/voice-actors/{voiceActorId}` | 성우 상세 |
| `GET` | `/projects/{projectId}/voice-actors/{voiceActorId}/members` | 담당 캐릭터 목록 |
| `GET` | `/projects/{projectId}/voice-actors/{voiceActorId}/credits` | 성우 크레딧 |

---

### 5-8. 악곡 탭 (Music)

**기능**
- 악곡 카탈로그 목록
- 곡 상세로 이동

---

### 5-9. 악곡 상세 (`MusicSongDetailPage`)

- **경로**: `/music/songs/:songId`
- **라우트 상수**: `AppRoutes.songDetail`

**기능**
- 곡 기본 정보 (제목, 아티스트, 앨범)
- 버전 선택 및 조회
- 가사 조회 (파트별 색상 구분)
- 콜 가이드 조회
- 크레딧 조회
- 미디어 링크 (유튜브, 스트리밍 등)
- 이용 가능 국가 정보
- 라이브 이벤트 컨텍스트
- 난이도 정보

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/music/songs/{songId}` | 악곡 상세 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/lyrics` | 가사 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/parts` | 파트 정보 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/call-guide` | 콜 가이드 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/versions` | 버전 목록 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/versions/{versionCode}` | 특정 버전 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/credits` | 크레딧 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/difficulty` | 난이도 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/media-links` | 미디어 링크 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/availability` | 이용 가능 정보 |
| `GET` | `/projects/{projectId}/music/songs/{songId}/live-context` | 라이브 컨텍스트 |

**상태 관리**: `musicSongDetailProvider`, `musicLyricsProvider`

---

### 5-10. 더보기 탭

**기능**
- 응원 가이드 → `/cheer-guides`
- 명대사 카드 → `/quotes`
- 성지순례 도감 → `/zukan`

---

### 5-11. 응원 가이드 목록 (`CheerGuidesPage`)

- **경로**: `/cheer-guides`
- **라우트 상수**: `AppRoutes.cheerGuides`

**기능**
- 응원 가이드 목록 (곡 제목, 아티스트, 난이도 별점)
- 가이드 상세로 이동

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/cheer-guides?projectId={projectId}` | 응원 가이드 목록 |

**상태 관리**: `cheerGuidesListProvider`, `selectedProjectKeyProvider`

---

### 5-12. 응원 가이드 상세 (`CheerGuideDetailPage`)

- **경로**: `/cheer-guides/:guideId`
- **라우트 상수**: `AppRoutes.cheerGuideDetail`

**기능**
- 섹션별 응원 텍스트 (가사 + 콜)
- 펜라이트 색상 표시
- 응원 유형 태그
- 타이밍 정보

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/cheer-guides/{guideId}` | 응원 가이드 상세 |

**상태 관리**: `cheerGuideDetailProvider`

---

### 5-13. 명대사 카드 (`QuotesPage`)

- **경로**: `/quotes`
- **라우트 상수**: `AppRoutes.quotes`

**기능**
- 명대사 카드 목록 (커서 페이지네이션)
- 캐릭터 + 에피소드 정보 표시
- 카드 배경 그라디언트/단색 렌더링
- 좋아요 토글
- 이미지로 저장 (RepaintBoundary → 갤러리 저장)
- 당겨서 새로고침

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/quotes?projectId={projectId}&cursor={cursor}&limit={limit}` | 명대사 카드 목록 |
| `POST` | `/quotes/{quoteId}/like` | 좋아요 |
| `DELETE` | `/quotes/{quoteId}/like` | 좋아요 취소 |

**상태 관리**: `quotesControllerProvider`, `selectedProjectKeyProvider`

---

### 5-14. 이벤트 캘린더 (`CalendarPage`)

- **경로**: `/calendar`
- **라우트 상수**: `AppRoutes.calendar`

**기능**
- 월 네비게이션 (이전/다음)
- 이벤트 타입별 색상 구분:
  - 캐릭터 생일 (분홍)
  - 성우 생일 (보라)
  - 발매 (초록)
  - 라이브 (황색)
  - 티켓 판매 (파란)
  - 방송 (청록)
  - 일반 이벤트 (회색)
- 날짜별 이벤트 그룹화 목록

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/calendar/events?year={year}&month={month}&projectId={projectId}` | 월별 캘린더 이벤트 |

**상태 관리**: `calendarEventsProvider`, `selectedProjectKeyProvider`

---

## 6. 커뮤니티 (Community / Feed)

> **⚠️ 특이사항: 커뮤니티 탭 전용 하단 네비게이션 바**
>
> 커뮤니티 탭(인덱스 4)은 다른 탭과 달리 **일반 5탭 `GBTBottomNav`가 사라지고** `_CommunitySubBottomNav`(커뮤니티 전용 하단 바)로 교체됩니다.
>
> **교체 조건**: 커뮤니티 루트 경로일 때만 표시 (`/community`, `/community/discover`, `/community/travel-reviews-tab`). 게시글 상세 등 하위 경로에서는 하단 바 자체가 숨겨짐(`null`).
>
> ### 커뮤니티 전용 하단 바 구성
>
> | 구성 요소 | 설명 |
> |---------|------|
> | **← 뒤로 버튼** | 커뮤니티 진입 전 마지막 화면(`_lastNonCommunityLocation`)으로 복귀. 이전 위치가 커뮤니티이거나 비어있으면 `/home`으로 이동 |
> | **피드 탭** | `/community` — 피드 아이콘 (`Icons.dynamic_feed_outlined`) |
> | **발견 탭** | `/community/discover` — 탐색 아이콘 (`Icons.explore_outlined`) |
> | **여행후기 탭** | `/community/travel-reviews-tab` — 리뷰 아이콘 (`Icons.rate_review_outlined`) |
>
> ### 플랫폼별 디자인 차이
>
> | 플랫폼 | 디자인 |
> |------|------|
> | **iOS / 기타** | 플로팅 Pill 형태 — 좌우 12px 마진, 상하 10px 패딩, `BackdropFilter` blur(18), 연속 곡률(ContinuousRectangleBorder 38/34px), 그라데이션 배경 + 테두리 |
> | **Android** | `Material elevation: 8` 전체 너비 바 — 일반 `BottomNavigationBar` 스타일 |
>
> ### 뒤로 가기(Android 시스템 버튼) 처리
>
> 커뮤니티 루트에서 Android 뒤로 버튼 → `_lastNonCommunityLocation`으로 `go()` (커뮤니티였거나 비어있으면 `/home`)
> 커뮤니티 루트가 아닌 경우 → GoRouter 기본 pop 처리

---

### 6-1. 피드 페이지 (`FeedPage`)

- **경로**: `/community` (탭 4)
- **라우트 상수**: `AppRoutes.community`
- **2개 탭**: 소식 / 커뮤니티

**기능**
- 소식 탭: 프로젝트 뉴스 목록 (히어로 + 컴팩트)
- 커뮤니티 탭: 게시글 목록 + 추천 피드
- 새 게시글 Pill 배너 (스크롤 중 새 글 도착 시)
- 프로젝트 선택기
- 게시글 작성 FAB

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/news` | 뉴스 목록 |
| `GET` | `/projects/{projectCode}/posts` | 커뮤니티 게시글 목록 |
| `GET` | `/projects/{projectCode}/posts/cursor` | 게시글 커서 기반 조회 |
| `GET` | `/community/recommended-feed/cursor` | 추천 피드 (커서) |
| `GET` | `/community/recommended-feed` | 추천 피드 (페이지) |
| `GET` | `/community/following-feed/cursor` | 팔로잉 피드 (커서) |

**상태 관리**: `newsListControllerProvider`, `postListControllerProvider`, `communityFeedControllerProvider`, `newPostsIndicatorProvider`

---

### 6-2. 게시글 상세 (`PostDetailPage`)

- **경로**: `/posts/:postId?projectCode={projectCode}`
- **라우트 상수**: `AppRoutes.postDetail`

**기능**
- 게시글 본문 조회
- 댓글 목록 (무한 스크롤)
- 댓글 작성 / 수정 / 삭제
- 좋아요 토글
- 북마크 토글
- 게시글/댓글 신고
- 번역 기능
- 작성자 팔로우/차단 메뉴
- 모더레이터: 게시글/댓글 삭제, 사용자 제재

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectCode}/posts/{postId}` | 게시글 상세 |
| `GET` | `/projects/{projectCode}/posts/{postId}/comments` | 댓글 목록 |
| `POST` | `/projects/{projectCode}/posts/{postId}/comments` | 댓글 작성 |
| `PUT` | `/projects/{projectCode}/posts/{postId}/comments/{commentId}` | 댓글 수정 |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/comments/{commentId}` | 댓글 삭제 |
| `GET` | `/projects/{projectCode}/posts/{postId}/likes` | 좋아요 상태 |
| `POST` | `/projects/{projectCode}/posts/{postId}/likes` | 좋아요 |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/likes` | 좋아요 취소 |
| `GET` | `/projects/{projectCode}/posts/{postId}/bookmarks` | 북마크 상태 |
| `POST` | `/projects/{projectCode}/posts/{postId}/bookmarks` | 북마크 |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/bookmarks` | 북마크 해제 |
| `POST` | `/community/reports` | 게시글/댓글 신고 |
| `POST` | `/community/translations` | 텍스트 번역 |
| `DELETE` | `/moderation/posts/{projectCode}/{postId}` | 게시글 삭제 (모더레이터) |
| `DELETE` | `/moderation/posts/{projectCode}/{postId}/comments/{commentId}` | 댓글 삭제 (모더레이터) |

**상태 관리**: `postDetailControllerProvider(postId)`, `userFollowControllerProvider(userId)`, `blockStatusControllerProvider(userId)`

---

### 6-3. 게시글 작성 (`PostCreatePage`)

- **경로**: `/posts/create`
- **라우트 상수**: `AppRoutes.postCreate`

**기능**
- 제목 입력 (최대 60자)
- 내용 입력 (최대 3,000자)
- 이미지 첨부 최대 6장 (갤러리/카메라/GIF)
- 토픽/태그 선택
- 임시 저장 자동 복구 (Draft autosave)
- 프로젝트 선택

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/community/post-options` | 토픽/태그 옵션 조회 |
| `POST` | `/projects/{projectCode}/posts` | 게시글 생성 |
| `POST` | `/uploads/images` | 이미지 업로드 |

**상태 관리**: `postComposeAutosaveControllerProvider`, `postComposeDraftStoreProvider`

---

### 6-4. 게시글 수정 (`PostEditPage`)

- **경로**: `/posts/:postId/edit?projectCode={projectCode}`
- **라우트 상수**: `AppRoutes.postEdit`

**기능**
- 기존 게시글 내용 수정
- 이미지 추가/삭제
- 토픽/태그 수정 (프로젝트 변경 불가)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `PUT` | `/projects/{projectCode}/posts/{postId}` | 게시글 수정 |
| `POST` | `/uploads/images` | 이미지 업로드 |

---

### 6-5. 북마크 목록 (`PostBookmarksPage`)

- **경로**: `/bookmarks`
- **라우트 상수**: `AppRoutes.postBookmarks`

**기능**
- 로컬 저장 북마크 게시글 목록
- 게시글 상세로 이동

**상태 관리**: `localPostBookmarksControllerProvider`

> 참고: 북마크는 로컬 스토리지 기반 (서버 API 없음)

---

### 6-6. 사용자 프로필 (`UserProfilePage`)

- **경로**: `/users/:userId`
- **라우트 상수**: `AppRoutes.userProfile`

**기능**
- 프로필 커버 이미지, 아바타, 소개
- 활성 칭호 표시
- 팔로워/팔로잉 통계
- 게시글 탭 / 댓글 탭
- 팔로우/언팔로우
- 차단/언차단
- 신고

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/{userId}` | 사용자 프로필 |
| `GET` | `/users/{userId}/follow` | 팔로우 상태 |
| `POST` | `/users/{userId}/follow` | 팔로우 |
| `DELETE` | `/users/{userId}/follow` | 언팔로우 |
| `GET` | `/users/{userId}/blocks` | 차단 상태 |
| `POST` | `/users/blocks` | 차단 |
| `DELETE` | `/users/{userId}/blocks` | 차단 해제 |
| `GET` | `/users/{userId}/activities` | 사용자 게시글/댓글 |
| `GET` | `/projects/{projectCode}/users/{userId}/posts` | 사용자 게시글 |
| `GET` | `/projects/{projectCode}/users/{userId}/comments` | 사용자 댓글 |

**상태 관리**: `userProfileByIdProvider(userId)`, `userActivityControllerProvider(userId)`, `userFollowControllerProvider(userId)`, `blockStatusControllerProvider(userId)`

---

### 6-7. 팔로워/팔로잉 목록 (`UserConnectionsPage`)

- **경로**: `/users/:userId/connections?tab={followers|following}`
- **라우트 상수**: `AppRoutes.userConnections`

**기능**
- 팔로워 목록 (검색 가능)
- 팔로잉 목록 (검색 가능)
- 사용자 카드 → 프로필 페이지

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/{userId}/followers` | 팔로워 목록 |
| `GET` | `/users/{userId}/following` | 팔로잉 목록 |

---

### 6-8. 여행 후기 작성 (`TravelReviewCreatePage`)

- **경로**: `/travel-review/create`
- **참고**: 현재 Mock 구현 (완전 구현 예정)

**기능**
- 제목/내용 입력
- 방문 장소 선택 (다중, 드래그 순서 변경)
- 지도에 경로/마커 미리보기 (폴리라인)
- 최소 1개 장소 필수

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/projects/{projectId}/places` | 장소 선택용 목록 조회 |

---

### 6-9. 여행 후기 상세 (`TravelReviewDetailPage`)

- **경로**: `/travel-review/:reviewId`
- **참고**: 현재 Mock 데이터 기반 (완전 구현 예정)

**기능**
- 작성자 정보, 제목, 방문 일정
- 본문 콘텐츠
- 경로 지도 (폴리라인 + 마커)
- 좋아요/댓글 버튼
- 수정/삭제 메뉴

---

## 7. 마이 (My)

### 마이 페이지 (`MyPage`)

- **경로**: `/mypage` (탭 3)
- **라우트 상수**: `AppRoutes.mypage`

**기능**
- 히어로 팬레벨 카드 (XP 링 + 등급 + 랭킹)
- 통계 스트립 (연속 출석일, 총 XP, 순위)
- 일일 체크인 버튼
- 탐방 & 계획 섹션:
  - 이벤트 달력 → `/calendar`
  - 방문 기록 → `/visits`
- 나의 컬렉션 섹션:
  - 즐겨찾기 → `/favorites`
  - 북마크 → `/bookmarks`
- 설정 → `/settings`

**상태 관리**: `userProfileControllerProvider`, `fanLevelControllerProvider`

---

### 7-1. 팬 레벨 (`FanLevelPage`)

- **경로**: `/mypage/fan-level`
- **라우트 상수**: `AppRoutes.fanLevel`

**기능**
- 팬 레벨 프로필 (등급 뱃지, XP)
- 현재 레벨 진행 상황 (XP 바)
- 최근 활동 및 XP 획득 내역
- 랭킹 표시
- 일일 출석 체크

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me/fan-level` | 팬 레벨 프로필 조회 |
| `POST` | `/users/me/fan-level/check-in` | 일일 출석 체크 |
| `POST` | `/users/me/fan-level/xp` | XP 획득 기록 |

**상태 관리**: `fanLevelControllerProvider`

---

### 7-2. 즐겨찾기 (`FavoritesPage`)

- **경로**: `/favorites`
- **라우트 상수**: `AppRoutes.favorites`
- **탭**: 전체 / 장소 / 이벤트 / 뉴스

**기능**
- 즐겨찾기 목록 (72px 썸네일 + 제목 + 타입 뱃지)
- 탭별 타입 필터
- 항목 탭 → 해당 상세 페이지
- 당겨서 새로고침

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me/favorites` | 즐겨찾기 목록 |

**상태 관리**: `favoritesControllerProvider`

---

### 7-3. 칭호 관리 (`TitleCatalogPage`)

- **경로**: `/mypage/titles`
- **라우트 상수**: `AppRoutes.titleCatalog`
- **파라미터**: `initialTitleId` (선택, 알림 딥링크용)

**기능**
- 칭호 카탈로그 (프로젝트/카테고리별 그룹)
- 획득/미획득/활성 상태 표시
- 칭호 적용
- 칭호 해제
- 활성 칭호 하이라이트

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/titles?projectKey={projectKey}` | 칭호 카탈로그 |
| `GET` | `/users/me/title?projectKey={projectKey}` | 활성 칭호 조회 |
| `PUT` | `/users/me/title` | 칭호 적용 |
| `DELETE` | `/users/me/title` | 칭호 해제 |

**상태 관리**: `titleCatalogProvider`, `activeTitleProvider`

---

## 8. 설정 (Settings)

### 8-1. 설정 메인 (`SettingsPage`)

- **경로**: `/settings`
- **라우트 상수**: `AppRoutes.settings`

**섹션 구성**
1. **프로필 카드** - 프로필 사진, 표시명, 이메일
2. **퀵 액션 그리드** - 즐겨찾기 / 방문 기록 / 통계
3. **계정 섹션** - 프로필 수정, 배너 꾸미기, 칭호 관리, 운영 센터, 계정 도구, 로그아웃
4. **덕질 모음** - 덕력, 캘린더, 도감, 응원 가이드, 명대사
5. **개인정보** - 개인정보 및 권리행사, 동의 이력
6. **알림** - 알림 설정
7. **앱 환경** - 테마(시스템/라이트/다크), 언어(시스템/한국어/English/日本語)
8. **지원** - 도움말, 피드백, 이용약관, 개인정보 처리방침, 위치정보 이용약관

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me` | 프로필 조회 |
| `POST` | `/auth/logout` | 로그아웃 |

**상태 관리**: `isAuthenticatedProvider`, `userProfileControllerProvider`, `themeModeProvider`, `localeProvider`, `appVersionProvider`

---

### 8-2. 프로필 편집 (`ProfileEditPage`)

- **경로**: `/settings/profile`
- **라우트 상수**: `AppRoutes.profileEdit`

**기능**
- 표시 이름 수정 (최대 30자)
- 소개 수정 (최대 200자)
- 프로필 사진 업로드 (1:1 비율 크롭)
- 배경 이미지 업로드 (16:9 비율 크롭)
- 이메일 표시 (마스킹)
- 권한 정보 표시 (읽기 전용)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me` | 프로필 조회 |
| `PATCH` | `/users/me` | 프로필 수정 (displayName, bio, avatarUrl, coverImageUrl) |
| `POST` | `/uploads/images` | 이미지 업로드 (WebP 변환) |

**상태 관리**: `userProfileControllerProvider`, `uploadsControllerProvider`

---

### 8-3. 알림 설정 (`NotificationSettingsPage`)

- **경로**: `/settings/notifications`
- **라우트 상수**: `AppRoutes.notificationSettings`

**기능**
- 활성 알림 수 뱃지
- 수신 채널 토글: 푸시 알림 ON/OFF, 이메일 알림 ON/OFF
- 콘텐츠 알림 선택 (푸시 ON 시 활성):
  - 라이브 이벤트
  - 즐겨찾기
  - 댓글
  - 팔로잉 글

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/notifications/settings` | 알림 설정 조회 |
| `PUT` | `/notifications/settings` | 알림 설정 수정 |

**상태 관리**: `notificationSettingsControllerProvider`

---

### 8-4. 계정 도구 (`AccountToolsPage`)

- **경로**: `/settings/account-tools`
- **라우트 상수**: `AppRoutes.accountTools`
- **3개 탭**: 차단 / 권한 요청 / 이의제기

**차단 탭 기능**
- 차단한 사용자 목록
- 차단 해제

**권한 요청 탭 기능**
- 현재 권한 수준 표시
- 권한 요청 생성: PLACE_EDITOR / COMMUNITY_MODERATOR
- 요청 내역 (대기/검토중/승인/반려)
- 요청 취소

**이의제기 탭 기능**
- 대상 유형 선택: 장소 방문 인증 / 라이브 출석 인증
- 실패한 인증 기록 선택
- 사유 선택: FALSE_REJECTION / GPS_INACCURACY / NETWORK_ISSUE / DEVICE_ISSUE / LOCATION_ERROR / OTHER
- 상세 설명 입력
- 이의제기 내역 조회

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/blocks` | 차단 목록 |
| `DELETE` | `/users/blocks/{targetUserId}` | 차단 해제 |
| `GET` | `/users/me` | 현재 권한 정보 |
| `GET` | `/role-requests` | 권한 요청 내역 |
| `POST` | `/role-requests` | 권한 요청 생성 |
| `DELETE` | `/role-requests/{requestId}` | 권한 요청 취소 |
| `GET` | `/verification/appeals?projectId=...` | 이의제기 내역 |
| `POST` | `/verification/appeals?projectId=...` | 이의제기 생성 |
| `GET` | `/verification/attempts/failed` | 실패한 인증 기록 |

**상태 관리**: `userBlocksControllerProvider`, `projectRoleRequestsControllerProvider`, `verificationAppealsControllerProvider`, `failedVerificationAttemptsProvider`

---

### 8-5. 커뮤니티 설정 (`CommunitySettingsPage`)

- **경로**: `/community-settings`
- **라우트 상수**: `AppRoutes.communitySettings`

**기능**
- 프로필 카드 (사진, 표시명, 이메일 마스킹)
- 내 프로필 / 팔로워 / 팔로잉 링크
- 알림함 / 북마크 / 게시글 작성 링크
- 계정 도구 / 운영 센터 / 전체 설정 링크

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/me` | 프로필 조회 |

---

### 8-6. 동의 이력 (`ConsentHistoryPage`)

- **경로**: `/settings/consents`
- **라우트 상수**: `AppRoutes.consentHistory`

**기능**
- 이용약관 / 개인정보처리방침 / 위치정보 이용약관 / 만 14세 확인 동의 이력
- 버전 및 동의 시각 표시
- 동의/거절 상태 아이콘

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/consents` | 동의 이력 조회 |
| `GET` | `/users/consent-status` | 필수 동의 상태 조회 |
| `POST` | `/users/consents` | 필수 동의 제출 |

**상태 관리**: `consentHistoryProvider`

---

### 8-7. 개인정보 및 권리행사 (`PrivacyRightsPage`)

- **경로**: `/settings/privacy-rights`
- **라우트 상수**: `AppRoutes.privacyRights`

**기능**
1. **자동번역 전송 설정** - 커뮤니티 자동번역 허용/거부 토글
2. **권리행사 요청 이력** - 최근 5개 (요청 유형, 시각, 상태)
3. **정보주체 권리행사**:
   - 내 데이터 열람 링크 (프로필/방문기록/즐겨찾기)
   - 처리정지 요청 (10자 이상 사유 필수)
   - 회원 탈퇴 (확인 다이얼로그)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/users/privacy/settings` | 개인정보 설정 조회 |
| `PATCH` | `/users/privacy/settings` | 개인정보 설정 수정 |
| `GET` | `/users/privacy/requests` | 권리행사 요청 이력 |
| `POST` | `/users/privacy/requests` | 권리행사 요청 생성 |
| `DELETE` | `/users/me` | 계정 삭제 (회원 탈퇴) |

---

### 8-8. 프로필 배너 피커 (`BannerPickerPage`)

- **경로**: `/banner-picker`
- **라우트 상수**: `AppRoutes.bannerPicker`

**기능**
- 배너 카탈로그 3열 그리드
- 희귀도별 테두리 색상 (Common / Rare / Epic / Legendary)
- 잠금 배너 오버레이 (해금 조건 표시)
- 배너 선택 하이라이트
- 배너 적용 (하단 Sticky 버튼)
- 배너 해제 (활성 배너 있을 때만)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/banners` | 배너 카탈로그 (해금 상태 포함) |
| `GET` | `/users/me/banner` | 현재 활성 배너 조회 |
| `PUT` | `/users/me/banner` | 배너 적용 |
| `DELETE` | `/users/me/banner` | 배너 해제 |

**상태 관리**: `bannerCatalogProvider`, `activeBannerProvider`

---

## 9. 공통/모달 페이지

### 9-1. 검색 (`SearchPage`)

- **경로**: `/search`
- **라우트 상수**: `AppRoutes.search`
- **쿼리 파라미터**: `initialQuery` (선택)

**기능**
- 통합 검색 (장소, 라이브, 뉴스, 게시글, 유닛, 프로젝트)
- 최근 검색어 관리 (추가/삭제/전체 삭제)
- 인기 검색어 랭킹
- 카테고리별 탐색 콘텐츠 수
- 탭 필터 (전체/장소/이벤트/뉴스)
- 디바운싱 검색 (300ms)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/search?q={query}&types={types}&page={n}&size={n}` | 통합 검색 |
| `GET` | `/search/discovery/popular?limit={n}` | 인기 검색어 |
| `GET` | `/search/discovery/categories?limit={n}` | 검색 카테고리 |

**상태 관리**: `searchControllerProvider`, `searchHistoryControllerProvider`, `searchPopularDiscoveryProvider`, `searchCategoryDiscoveryProvider`

---

### 9-2. 알림 (`NotificationsPage`)

- **경로**: `/notifications`
- **라우트 상수**: `AppRoutes.notifications`

**기능**
- 알림 목록 (페이지네이션)
- 섹션 그룹화 (오늘 / 이번 주 / 이전)
- 읽음/미읽음 필터
- 스와이프로 개별 삭제
- 전체 읽음 처리
- 전체 삭제 (확인 다이얼로그)
- 알림 설정 접근 → `/settings/notifications`
- 백그라운드 자동 새로고침 (40초)
- 앱 재개 시 자동 새로고침
- 알림 탭 → 타입별 딥링크 이동

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/notifications?page={n}&size={n}` | 알림 목록 |
| `POST` | `/notifications/{id}/read` | 알림 읽음 처리 |
| `DELETE` | `/notifications/{id}` | 개별 알림 삭제 |
| `DELETE` | `/notifications` | 전체 알림 삭제 |

**상태 관리**: `notificationsControllerProvider`

---

### 9-3. 광고 슬롯 (Ads)

> 독립 페이지 없음, 홈/피드 등 여러 페이지에 삽입

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/ads/decision?slot={slot}&ordinal={n}&projectKey={key}` | 광고 슬롯 결정 |
| `POST` | `/ads/events` | 광고 이벤트 추적 (노출/클릭) |

---

### 9-4. GPS 장소/라이브 검증 (Verification)

> 장소 상세 / 라이브 상세 페이지에서 호출되는 백엔드 로직

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/verification/config` | 검증 설정 조회 |
| `GET` | `/verification/challenge` | 검증 챌린지 |
| `POST` | `/verification/keys` | 디바이스 키 등록 |
| `POST` | `/projects/{projectId}/places/{placeId}/verification` | 장소 GPS 검증 |
| `POST` | `/projects/{projectId}/live-events/{liveEventId}/verification` | 라이브 GPS 검증 |

---

### 9-5. 파일 업로드 (Uploads)

> 프로필 수정, 게시글 작성, 방문 후기 등 여러 페이지에서 공통 사용

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `POST` | `/uploads` | 파일 직접 업로드 (multipart/form-data) |
| `POST` | `/uploads/presigned-url` | Presigned URL 요청 |
| `POST` | `/uploads/{uploadId}/confirm` | 업로드 완료 확인 |
| `GET` | `/uploads/my` | 내 업로드 목록 |
| `DELETE` | `/uploads/{uploadId}` | 업로드 삭제 |

---

## 10. 관리자 운영 센터 (Admin Ops)

### 운영 센터 (`AdminOpsPage`)

- **경로**: `/settings/admin`
- **라우트 상수**: `AppRoutes.adminOps`
- **권한 필요**: COMMUNITY_MODERATOR 이상

**기능**
- 관리자 대시보드 요약 조회
- 신고 관리 (목록/상세/할당/상태 업데이트)
- 권한 요청 심사 (승인/거절)
- 미디어 삭제 요청 관리 (승인/반려)
- 프로젝트 역할 부여/회수
- 사용자 제재 (ban/unban)

**API 엔드포인트**

| 메서드 | 엔드포인트 | 설명 |
|------|----------|------|
| `GET` | `/admin/dashboard` | 관리자 대시보드 요약 |
| `GET` | `/admin/moderation/dashboard` | 모더레이션 대시보드 |
| `GET` | `/admin/community/reports` | 신고 목록 (상태 필터, 페이지네이션) |
| `GET` | `/admin/community/reports/{reportId}` | 신고 상세 |
| `PATCH` | `/admin/community/reports/{reportId}/assign` | 신고 담당자 할당 |
| `PATCH` | `/admin/community/reports/{reportId}` | 신고 상태 업데이트 |
| `GET` | `/admin/projects/role-requests` | 권한 요청 목록 |
| `PATCH` | `/admin/projects/role-requests/{requestId}/review` | 권한 요청 심사 |
| `POST` | `/projects/{projectId}/roles/grant` | 프로젝트 역할 부여 |
| `POST` | `/projects/{projectId}/roles/revoke` | 프로젝트 역할 회수 |
| `POST` | `/admin/users/{userId}/access-grants` | 사용자 접근 권한 부여 |
| `POST` | `/admin/users/{userId}/access-grants/{grantId}/revoke` | 접근 권한 회수 |
| `GET` | `/admin/media-deletions` | 미디어 삭제 요청 목록 |
| `POST` | `/admin/media-deletions/{requestId}/approve` | 삭제 요청 승인 |
| `POST` | `/admin/media-deletions/{requestId}/reject` | 삭제 요청 반려 |
| `GET` | `/moderation/bans/{projectCode}` | 프로젝트 제재 목록 |
| `GET` | `/moderation/bans/{projectCode}/{userId}` | 제재 상태 조회 |
| `POST` | `/moderation/bans/{projectCode}/{userId}` | 사용자 제재 |
| `DELETE` | `/moderation/bans/{projectCode}/{userId}` | 제재 해제 |

---

## 11. 특별 구현 사항 및 주의점

### 11-1. GPS 검증 (Verification) — 복잡한 다단계 보안 흐름

> **파일**: `verification/application/token_service.dart`, `verification_key_service.dart`

장소 방문 인증 및 라이브 출석 인증은 단순 API 호출이 아닌, **5단계 보안 흐름**으로 구성됩니다.

**흐름 (TokenService.buildToken)**
```
1. 챌린지(Nonce) 조회  →  GET /verification/challenge
2. 공개키 설정 조회    →  GET /verification/config
3. GPS 좌표 취득       →  device GPS (lat, lon, accuracyM, isMocked)
4. JWS 서명           →  디바이스 개인키로 클레임 서명 (RS256)
5. JWE 암호화         →  서버 공개키로 JWS 암호화 (RSA-OAEP-256 + A256GCM)
```

**클레임(Claims) 구조**
```json
{
  "lat": 35.681,
  "lon": 139.767,
  "timestamp": 1710000000,
  "accuracyM": 5.0,
  "isMocked": false
}
```

**공개키 형식 다중 지원** (우선순위 순)
- JWK JSON 형식 (`{...}`)
- PEM 형식 (`-----BEGIN PUBLIC KEY-----`)
- Base64 인코딩된 PEM

**디바이스 키 관리 (VerificationKeyService)**
- RSA 2048bit 키쌍을 앱 최초 실행 시 생성 → Secure Storage 저장
- deviceId 형식: `device-{ios|android|web}-{base64url_16bytes}`
- keyId 형식: `device-key-{base64url_16bytes}`
- 키 등록: `POST /verification/keys` (등록 완료 후 `verificationKeyRegisteredAt` 로컬 저장)
- 이미 등록된 키는 재등록하지 않음 (로컬 플래그 확인)

**GPS 모킹 감지**
- `isMocked: true`인 경우 `mockProvider: 'device'` 클레임 추가
- 서버에서 모킹 감지 시 인증 거부 가능

---

### 11-2. 광고 시스템 — 레거시 API 폴백 패턴

> **파일**: `ads/data/datasources/ads_remote_data_source.dart`

광고 API는 **v2 → v1 자동 폴백** 패턴을 사용합니다.

```
슬롯 결정 조회:
  1차: GET /api/v2/ads/decisions
  404 발생 시 → 2차: GET /api/v1/ads/decisions

이벤트 추적:
  1차: POST /api/v2/ads/events
  404 발생 시 → 2차: POST /api/v1/ads/event
```

쿼리 파라미터에 `projectKey`와 `projectCode`를 **동시에 전송** (레거시 서버 호환)

응답이 `null` 또는 비-Map이면 광고 없음으로 처리 (표시 안 함)

---

### 11-3. 라이브 이벤트 — 클라이언트 사이드 필터링

> **파일**: `live_events/data/datasources/live_events_remote_data_source.dart`

라이브 이벤트 API는 유닛(밴드) 필터링을 서버에서 제공하지 않습니다.

- 기본 한 번에 **500개** 조회 (`size=500`)
- **유닛/연도 필터링은 클라이언트에서** 처리 (`selectedLiveBandIdsProvider`, `selectedLiveEventYearProvider`)

**유연한 JSON 디코딩**
서버 응답 형식이 다양할 수 있어 다음 키 순서로 탐색:
```
배열 직접 수신 → 그대로 사용
객체 수신 시 → 'items' > 'content' > 'data' > 'results' 순서로 탐색
```

**bool 필드 안전 파싱** (`_boolOrFallback`)
- `bool`, `num` (0/1), `String` ('true'/'yes'/'y' 대소문자 무시) 모두 처리

---

### 11-4. 게시글 자동저장 (Draft Autosave)

> **파일**: `feed/application/post_compose_autosave_controller.dart`

게시글 작성 중 **1.2초 디바운스** 후 로컬 자동저장합니다.

**저장 트리거 조건**
- 제목/내용/이미지/태그 중 하나라도 실질적인 내용이 있을 때만 저장
- 모두 비어있으면 기존 Draft 삭제

**Draft 구조**
```dart
{
  title: String,
  content: String,
  imagePaths: List<String>,
  savedAt: DateTime,
  projectCode: String?,
  topic: String?,
  tags: List<String>,
}
```

**UI 표시**: `"임시 저장됨 · HH:MM"` (24시간 포맷)

---

### 11-5. 이미지 업로드 — 두 가지 방식

**방식 1: 직접 업로드** (Multipart)
```
POST /uploads  →  multipart/form-data
POST /uploads/{uploadId}/confirm  →  업로드 완료 확인
```

**방식 2: Presigned URL 업로드** (S3 직접 업로드)
```
POST /uploads/presigned-url  →  S3 Presigned URL 발급
PUT {presignedUrl}           →  S3에 직접 바이트 업로드
  - connectTimeout: 15초
  - sendTimeout: 30초
  - receiveTimeout: 30초
```

이미지는 업로드 전 **WebP 형식으로 자동 변환** (최적화)
프로필 사진은 **1:1 비율 강제 크롭**, 배경은 **16:9 비율 강제 크롭**

---

### 11-6. 미완성(Mock/WIP) 기능

| 기능 | 페이지 | 상태 | 비고 |
|-----|--------|------|------|
| 여행 후기 작성 | `TravelReviewCreatePage` | Mock 구현 | 제출 시 2초 지연 후 완료 처리 |
| 여행 후기 상세 | `TravelReviewDetailPage` | Mock 데이터 | 하드코딩 더미 데이터 사용 |
| 뉴스 북마크 | `NewsDetailPage` | TODO | 버튼은 있으나 기능 미구현 |
| 뉴스 공유 | `NewsDetailPage` | TODO | 버튼은 있으나 기능 미구현 |
| 장소 공유 | `PlaceDetailPage` | TODO | 버튼은 있으나 기능 미구현 |
| 라이브 이벤트 공유 | `LiveEventDetailPage` | TODO | 버튼은 있으나 기능 미구현 |
| 크래시 리포팅 | `AppLogger` | TODO | Sentry 등 외부 서비스 연동 필요 |
| 도움말/피드백 | `SettingsPage` | 준비 중 | "준비 중" 표시만 있음 |

---

### 11-7. 팬 레벨 XP 활동 타입 매핑

> **파일**: `fan_level/data/datasources/fan_level_remote_data_source.dart`

XP 적립 시 활동 타입이 엔티티 타입으로 자동 변환됩니다.

| 활동 타입 (`activityType`) | 엔티티 타입 (`entityType`) |
|--------------------------|--------------------------|
| `PLACE_VISIT` | `PLACE` |
| `LIVE_ATTENDANCE` | `LIVE_EVENT` |
| `POST_CREATED` | `POST` |
| `COMMENT_CREATED` | `COMMENT` |
| 기타 | 그대로 사용 |

---

### 11-8. 커뮤니티 모더레이션

**모더레이터 전용 기능** (COMMUNITY_MODERATOR 권한 필요)

| 기능 | API |
|-----|-----|
| 게시글 강제 삭제 | `DELETE /moderation/posts/{projectCode}/{postId}` |
| 댓글 강제 삭제 | `DELETE /moderation/posts/{projectCode}/{postId}/comments/{commentId}` |
| 사용자 제재 | `POST /moderation/bans/{projectCode}/{userId}` |
| 제재 해제 | `DELETE /moderation/bans/{projectCode}/{userId}` |
| 신고 할당/처리 | `PATCH /admin/community/reports/{reportId}` |

신고 레이트 리밋: `reportRateLimiterProvider`로 신고 스팸 방지

---

## 12. 전체 API 엔드포인트 색인

> Base URL: `/api/v1`
> 인증: Bearer Token (JWT)

### 인증 (Auth)

| 메서드 | 엔드포인트 |
|------|----------|
| `POST` | `/auth/login` |
| `POST` | `/auth/register` |
| `GET` | `/auth/callback` |
| `POST` | `/auth/logout` |

### 사용자 (Users)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/users/me` |
| `PATCH` | `/users/me` |
| `DELETE` | `/users/me` |
| `GET` | `/users/{userId}` |
| `GET` | `/users/me/fan-level` |
| `POST` | `/users/me/fan-level/check-in` |
| `POST` | `/users/me/fan-level/xp` |
| `GET` | `/users/me/banner` |
| `PUT` | `/users/me/banner` |
| `DELETE` | `/users/me/banner` |
| `GET` | `/users/me/title` |
| `PUT` | `/users/me/title` |
| `DELETE` | `/users/me/title` |
| `GET` | `/users/me/favorites` |
| `POST` | `/users/me/favorites` |
| `DELETE` | `/users/me/favorites` |
| `GET` | `/users/me/visits` |
| `GET` | `/users/me/visits/{visitId}` |
| `GET` | `/users/me/visits/summary` |
| `GET` | `/users/me/access-level` |
| `GET` | `/users/blocks` |
| `DELETE` | `/users/blocks/{targetUserId}` |
| `POST` | `/users/blocks` |
| `DELETE` | `/users/{userId}/blocks` |
| `GET` | `/users/{userId}/blocks` |
| `GET` | `/users/{userId}/follow` |
| `POST` | `/users/{userId}/follow` |
| `DELETE` | `/users/{userId}/follow` |
| `GET` | `/users/{userId}/followers` |
| `GET` | `/users/{userId}/following` |
| `GET` | `/users/{userId}/activities` |
| `GET` | `/users/consents` |
| `GET` | `/users/consent-status` |
| `POST` | `/users/consents` |
| `GET` | `/users/privacy/settings` |
| `PATCH` | `/users/privacy/settings` |
| `GET` | `/users/privacy/requests` |
| `POST` | `/users/privacy/requests` |

### 홈 (Home)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/home/summary` |
| `GET` | `/home/summary/by-project` |
| `GET` | `/home/banners` |

### 알림 (Notifications)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/notifications` |
| `POST` | `/notifications/{id}/read` |
| `DELETE` | `/notifications/{id}` |
| `DELETE` | `/notifications` |
| `GET` | `/notifications/settings` |
| `PUT` | `/notifications/settings` |
| `DELETE` | `/notifications/devices/{deviceId}` |

### 검색 (Search)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/search` |
| `GET` | `/search/discovery/popular` |
| `GET` | `/search/discovery/categories` |

### 프로젝트 (Projects)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/projects` |
| `GET` | `/projects/{projectId}/units` |
| `GET` | `/projects/{projectId}/units/{unitId}` |
| `GET` | `/projects/{projectId}/units/{unitId}/members` |
| `GET` | `/projects/{projectId}/units/{unitId}/members/{memberId}` |
| `GET` | `/projects/{projectId}/units/voice-actors` |
| `GET` | `/projects/{projectId}/units/voice-actors/{voiceActorId}` |
| `GET` | `/projects/{projectId}/units/voice-actors/{voiceActorId}/members` |
| `GET` | `/projects/{projectId}/units/voice-actors/{voiceActorId}/credits` |
| `GET` | `/projects/{projectId}/news` |
| `GET` | `/projects/{projectId}/news/{newsId}` |
| `GET` | `/projects/{projectId}/rankings/most-visited` |
| `GET` | `/projects/{projectId}/rankings/most-liked` |
| `GET` | `/projects/{projectId}/rankings/users` |
| `POST` | `/projects/{projectId}/roles/grant` |
| `POST` | `/projects/{projectId}/roles/revoke` |

### 장소 (Places)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/projects/{projectId}/places` |
| `GET` | `/projects/{projectId}/places/{placeId}` |
| `GET` | `/projects/{projectId}/places/within-bounds` |
| `GET` | `/projects/{projectId}/places/nearby` |
| `GET` | `/projects/{projectId}/places/regions/available` |
| `GET` | `/projects/{projectId}/places/regions/filter` |
| `GET` | `/projects/{projectId}/places/regions/map-bounds` |
| `GET` | `/places/{placeId}/guides` |
| `GET` | `/places/{placeId}/guides/high-priority` |
| `GET` | `/places/{placeId}/comments` |
| `POST` | `/places/{placeId}/comments` |
| `DELETE` | `/places/{placeId}/comments/{commentId}` |
| `GET` | `/{entityType}/{entityId}/contributors` |

### 라이브 이벤트 (Live Events)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/projects/{projectId}/live-events` |
| `GET` | `/projects/{projectId}/live-events/{eventId}` |
| `GET` | `/projects/{projectId}/live-events/attendances` |
| `GET` | `/projects/{projectId}/live-events/{eventId}/attendance` |
| `PUT` | `/projects/{projectId}/live-events/{eventId}/attendance` |
| `GET` | `/projects/{projectId}/live-events/{eventId}/setlist` |

### 커뮤니티/피드 (Community / Feed)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/projects/{projectCode}/posts` |
| `GET` | `/projects/{projectCode}/posts/cursor` |
| `GET` | `/projects/{projectCode}/posts/{postId}` |
| `POST` | `/projects/{projectCode}/posts` |
| `PUT` | `/projects/{projectCode}/posts/{postId}` |
| `DELETE` | `/projects/{projectCode}/posts/{postId}` |
| `GET` | `/projects/{projectCode}/posts/{postId}/comments` |
| `POST` | `/projects/{projectCode}/posts/{postId}/comments` |
| `PUT` | `/projects/{projectCode}/posts/{postId}/comments/{commentId}` |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/comments/{commentId}` |
| `GET` | `/projects/{projectCode}/posts/{postId}/likes` |
| `POST` | `/projects/{projectCode}/posts/{postId}/likes` |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/likes` |
| `GET` | `/projects/{projectCode}/posts/{postId}/bookmarks` |
| `POST` | `/projects/{projectCode}/posts/{postId}/bookmarks` |
| `DELETE` | `/projects/{projectCode}/posts/{postId}/bookmarks` |
| `GET` | `/projects/{projectCode}/posts/search` |
| `GET` | `/projects/{projectCode}/posts/trending` |
| `GET` | `/projects/{projectCode}/users/{userId}/posts` |
| `GET` | `/projects/{projectCode}/users/{userId}/comments` |
| `GET` | `/community/recommended-feed` |
| `GET` | `/community/recommended-feed/cursor` |
| `GET` | `/community/following-feed/cursor` |
| `GET` | `/community/post-options` |
| `POST` | `/community/translations` |
| `GET` | `/community/subscriptions` |
| `POST` | `/community/reports` |
| `GET` | `/community/reports/me` |
| `GET` | `/community/reports/{reportId}` |
| `DELETE` | `/community/reports/{reportId}` |
| `GET` | `/moderation/bans/{projectCode}` |
| `GET` | `/moderation/bans/{projectCode}/{userId}` |
| `POST` | `/moderation/bans/{projectCode}/{userId}` |
| `DELETE` | `/moderation/bans/{projectCode}/{userId}` |
| `DELETE` | `/moderation/posts/{projectCode}/{postId}` |
| `DELETE` | `/moderation/posts/{projectCode}/{postId}/comments/{commentId}` |

### 악곡 (Music)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/projects/{projectId}/music/songs/{songId}` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/lyrics` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/parts` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/call-guide` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/versions` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/versions/{versionCode}` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/credits` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/difficulty` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/media-links` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/availability` |
| `GET` | `/projects/{projectId}/music/songs/{songId}/live-context` |

### 캘린더 (Calendar)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/calendar/events` |

### 성지순례 도감 (Zukan)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/zukan/collections` |
| `GET` | `/zukan/collections/{collectionId}` |

### 칭호 (Titles)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/titles` |

### 명대사 (Quotes)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/quotes` |
| `POST` | `/quotes/{quoteId}/like` |
| `DELETE` | `/quotes/{quoteId}/like` |

### 응원 가이드 (Cheer Guides)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/cheer-guides` |
| `GET` | `/cheer-guides/{guideId}` |

### 배너 (Banners)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/banners` |

### 권한 요청 (Role Requests)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/role-requests` |
| `GET` | `/role-requests/{requestId}` |
| `POST` | `/role-requests` |
| `DELETE` | `/role-requests/{requestId}` |

### 검증 (Verification)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/verification/config` |
| `GET` | `/verification/challenge` |
| `POST` | `/verification/keys` |
| `POST` | `/projects/{projectId}/places/{placeId}/verification` |
| `POST` | `/projects/{projectId}/live-events/{liveEventId}/verification` |
| `GET` | `/verification/appeals` |
| `POST` | `/verification/appeals` |
| `GET` | `/verification/attempts/failed` |

### 업로드 (Uploads)

| 메서드 | 엔드포인트 |
|------|----------|
| `POST` | `/uploads` |
| `POST` | `/uploads/presigned-url` |
| `POST` | `/uploads/{uploadId}/confirm` |
| `GET` | `/uploads/my` |
| `DELETE` | `/uploads/{uploadId}` |

### 광고 (Ads)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/ads/decision` |
| `POST` | `/ads/events` |

### 관리자 (Admin)

| 메서드 | 엔드포인트 |
|------|----------|
| `GET` | `/admin/dashboard` |
| `GET` | `/admin/moderation/dashboard` |
| `GET` | `/admin/community/reports` |
| `GET` | `/admin/community/reports/{reportId}` |
| `PATCH` | `/admin/community/reports/{reportId}/assign` |
| `PATCH` | `/admin/community/reports/{reportId}` |
| `GET` | `/admin/projects/role-requests` |
| `PATCH` | `/admin/projects/role-requests/{requestId}/review` |
| `POST` | `/admin/users/{userId}/access-grants` |
| `POST` | `/admin/users/{userId}/access-grants/{grantId}/revoke` |
| `GET` | `/admin/media-deletions` |
| `POST` | `/admin/media-deletions/{requestId}/approve` |
| `POST` | `/admin/media-deletions/{requestId}/reject` |

---

---

*문서 생성: 2026-03-19 | 총 페이지 수: 약 50개 | 총 API 엔드포인트 수: 약 160개 | 미구현 기능: 7개*
