# 걸즈밴드타비 5탭 아키텍처 가이드

## 개요

PDF 가이드라인에 기반한 5탭 구조 (홈/장소/라이브/소식/설정) Flutter 앱 아키텍처 설계 문서입니다.

## 전체 아키텍처

### 1. Clean Architecture + Feature-first 구조

```
lib/
├── main.dart                           # 앱 진입점
├── app.dart                            # MaterialApp 설정 (GirlsBandTabiApp)
├── core/                               # 공통 인프라
│   ├── config/                         # 앱 설정
│   ├── constants/                      # 상수 정의
│   ├── error/                          # 에러 처리
│   ├── network/                        # 네트워크 클라이언트
│   ├── router/                         # GoRouter 라우팅
│   ├── theme/                          # KT 디자인 시스템
│   ├── utils/                          # 유틸리티
│   └── widgets/                        # 공통 위젯 (KTFeedCard 등)
├── features/                           # Feature 모듈
│   ├── home/                           # 홈 탭
│   ├── places/                         # 장소 탭
│   ├── live_events/                    # 라이브 탭
│   ├── news/                           # 소식 탭 (커뮤니티 + 뉴스)
│   ├── settings/                       # 설정 탭
│   ├── auth/                           # 인증 (기존)
│   └── profile/                        # 프로필 (기존)
└── shared/                             # 공유 리소스
```

### 2. 각 Feature 내부 구조

```
features/<feature>/
├── presentation/                       # UI 레이어
│   ├── pages/                          # 화면 (Screen)
│   ├── widgets/                        # 위젯
│   └── controllers/                    # 상태 관리
├── application/                        # 애플리케이션 레이어
│   ├── usecases/                       # 비즈니스 로직
│   ├── providers/                      # Riverpod 프로바이더
│   └── controllers/                    # 컨트롤러
├── domain/                             # 도메인 레이어
│   ├── entities/                       # 엔티티
│   ├── repositories/                   # 레포지토리 인터페이스
│   └── usecases/                       # 유스케이스
└── data/                               # 데이터 레이어
    ├── models/                         # 데이터 모델
    ├── datasources/                    # 데이터 소스
    └── repositories/                   # 레포지토리 구현
```

## 5탭 구조 및 기능

### 1. 홈 탭 (`/home`)
**목적**: 카드형 콘텐츠 피드 및 개요
- **UI 패턴**: 치지직 앱 홈 피드 참고
- **주요 기능**:
  - 다가오는 라이브 이벤트 섹션
  - 인기 장소 섹션
  - 최신 밴드 소식 섹션
- **구현**: `HomeScreen` - 섹션별 카드 UI로 구성

### 2. 장소 탭 (`/places`)
**목적**: 지도 + 바텀시트 패턴
- **UI 패턴**: Airbnb, 네이버 지도 참고
- **주요 기능**:
  - 지도 기반 장소 탐색
  - 바텀시트 장소 리스트
  - 장소 상세 정보 + 방문 인증 CTA
  - 방문 통계 시각화
- **구현**: `PlaceListScreen`, `PlaceMapScreen`

### 3. 라이브 탭 (`/live`)
**목적**: 공연/라이브 이벤트 목록 및 상세
- **UI 패턴**: Airbnb 숙소 목록 카드 참고
- **주요 기능**:
  - 라이브 이벤트 카드형 목록
  - 라이브 상세 정보 + 방문 인증
  - 밴드별 통계 (스와이프 네비게이션)
  - 진행중/예정 필터링
- **구현**: `LiveEventsListPage`

### 4. 소식 탭 (`/news`) - 기존 "정보" 탭
**목적**: 커뮤니티 & 뉴스 피드
- **UI 패턴**: 당근마켓 동네생활, 위버스 참고
- **주요 기능**:
  - 커뮤니티 탭: 사용자 게시글 피드
  - 공식 뉴스 탭: 밴드 공지사항/뉴스
  - 게시글 작성 플로팅 액션 버튼
  - 공식/일반 게시물 구분 (뱃지)
- **구현**: `NewsScreen` - TabBar로 커뮤니티/공식뉴스 구분

### 5. 설정 탭 (`/settings`) - 기존 "전체" 탭
**목적**: 계정 및 앱 설정 관리
- **UI 패턴**: 직방 설정 화면 참고
- **주요 기능**:
  - 프로필 요약 (방문/인증/게시글 통계)
  - 계정 관리 (프로필, 비밀번호, JWT 인증)
  - 앱 설정 (알림, 언어, 테마)
  - 기타 (도움말, 약관, 앱 정보)
- **구현**: `SettingsScreen` - 섹션별 리스트 UI

## 라우팅 시스템

### GoRouter 구조
```dart
StatefulShellRoute.indexedStack(
  branches: [
    // 홈
    StatefulShellBranch(routes: [GoRoute(path: '/home')]),
    // 장소
    StatefulShellBranch(routes: [GoRoute(path: '/places')]),
    // 라이브
    StatefulShellBranch(routes: [GoRoute(path: '/live')]),
    // 소식
    StatefulShellBranch(routes: [GoRoute(path: '/news')]),
    // 설정
    StatefulShellBranch(routes: [GoRoute(path: '/settings')]),
  ],
)
```

### 네비게이션 아이콘
| 탭 | 아이콘 (비활성) | 아이콘 (활성) | 라벨 |
|-----|---------------|-------------|------|
| 홈 | `Icons.home_outlined` | `Icons.home_rounded` | '홈' |
| 장소 | `Icons.temple_buddhist_outlined` | `Icons.temple_buddhist` | '장소' |
| 라이브 | `Icons.music_note_outlined` | `Icons.music_note` | '라이브' |
| 소식 | `Icons.newspaper_outlined` | `Icons.newspaper` | '소식' |
| 설정 | `Icons.settings_outlined` | `Icons.settings` | '설정' |

## 핵심 구현 사항

### 1. 상태 관리
- **Riverpod** 사용
- Feature별 독립적인 Provider
- 전역 상태 최소화

### 2. 디자인 시스템
- **KT UXD 디자인 시스템** 적용
- `KTFeedCard`, `KTBottomNavigation` 등 공통 컴포넌트
- 일관된 테마 및 스타일링

### 3. 접근성 및 성능
- 텍스트 배율 제한 (0.8~1.4)
- Rebuild scope 최소화
- 메모리 효율적인 ListView.builder 사용

### 4. 오프라인 지원
- SharedPreferences를 통한 설정 지속성
- 캐시 전략 구현

## 주요 변경 사항

### 기존 → 신규
1. **"정보" 탭** → **"소식" 탭**
   - PDF 가이드라인 권장사항 반영
   - 커뮤니티 + 뉴스 피드 통합

2. **"전체" 탭** → **"설정" 탭**  
   - 더 직관적인 설정 중심 구조
   - 마이페이지 요소 통합

3. **"성지" 라벨** → **"장소" 라벨**
   - 더 포괄적이고 이해하기 쉬운 명칭

4. **MaterialApp** → **MaterialApp.router**
   - GoRouter 기반 선언적 라우팅

## 다음 단계

1. **Feature 별 상세 구현**
   - 각 탭별 도메인 로직 구현
   - API 연동 및 데이터 플로우 구축

2. **KT UXD 컴포넌트 확장**
   - PDF에서 제시한 UI 패턴 구현
   - 애니메이션 및 인터랙션 추가

3. **성능 최적화**
   - 이미지 캐싱 및 레이지 로딩
   - 네트워크 요청 최적화

4. **테스트 및 접근성**
   - Unit/Widget/Integration 테스트 추가
   - 접근성 검증 및 개선

---

**문서 버전**: 1.0  
**작성일**: 2024-11-30  
**작성자**: Claude (mobile-app-developer)  
**기반 문서**: 걸즈밴드 인포 앱 디자인 레퍼런스 조사 PDF