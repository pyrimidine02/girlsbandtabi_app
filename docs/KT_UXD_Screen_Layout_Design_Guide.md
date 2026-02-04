# 걸즈밴드 인포 앱 화면별 레이아웃 설계 가이드

## 개요

이 문서는 디자인 레퍼런스를 기반으로 한 걸즈밴드 인포 앱의 화면별 레이아웃 설계 가이드입니다. KT UXD 디자인 시스템을 활용하여 일관성 있는 사용자 경험을 제공합니다.

## 전체 앱 구조

### 5탭 아키텍처
- **홈**: 콘텐츠 피드 및 개요
- **장소**: 성지순례 지도 탐색  
- **라이브**: 이벤트 목록 및 상세
- **뉴스**: 커뮤니티 및 공식 소식
- **설정**: 프로필 및 앱 설정

## 화면별 상세 설계

### 1. 홈 화면 (home_screen.dart)

#### 레이아웃 구조
```
AppBar (KTTopNavigation)
├── SingleChildScrollView
    ├── HomeBanner (히어로 배너)
    ├── HorizontalEventList (다가오는 라이브)
    ├── HorizontalPlaceList (인기 장소)  
    └── VerticalNewsList (최신 뉴스)
```

#### 디자인 패턴
- **카드형 섹션 구성**: 각 콘텐츠를 시각적으로 구분
- **스크롤 가능한 수직 레이아웃**: 다양한 정보 한눈에 보기
- **CTA 중심**: 각 섹션에서 해당 탭으로의 진입점 제공

#### 상태 관리
- `homeViewModelProvider`를 통한 데이터 로딩
- AsyncValue 패턴으로 로딩/에러 상태 처리

### 2. 장소 탭 - 지도 화면 (place_map_screen.dart)

#### 레이아웃 구조 (Airbnb, 네이버지도 패턴)
```
AppBar
├── Stack
    ├── FlutterMap (지도 배경)
    │   ├── TileLayer
    │   └── MarkerLayer
    ├── DraggableScrollableSheet (바텀시트)
    │   ├── Handle Bar
    │   ├── PlaceDetailView (선택된 장소)
    │   └── PlaceList (장소 목록)
    └── FloatingActionButton (위치 버튼)
```

#### 인터랙션 패턴
- **지도 + 바텀시트 조합**: 지도를 보면서 하단에 정보 표시
- **마커 탭으로 상세 보기**: 바텀시트가 확장되며 상세 정보 표시
- **드래그 제스처**: 바텀시트 높이 조절 가능

### 3. 장소 상세 화면 (place_detail_screen.dart)

#### 레이아웃 구조 (Foursquare 패턴)
```
AppBar
├── SingleChildScrollView
    ├── Hero Image (장소 대표 이미지)
    ├── Place Info (장소 기본 정보)
    ├── Check-in Section (방문 인증 CTA)
    ├── Description (장소 설명)
    └── Reviews (리뷰 목록)
```

#### 핵심 기능
- **방문 인증**: 체크인 버튼으로 스탬프 수집
- **리뷰 시스템**: 사용자 리뷰 작성 및 조회
- **이미지 갤러리**: 장소 관련 사진들

### 4. 라이브/이벤트 화면들

#### 4-1. 이벤트 목록 (event_list_screen.dart)
```
AppBar  
├── EventCalendar (달력 뷰)
└── Event List (선택된 날짜의 이벤트들)
```

#### 4-2. 이벤트 상세 (event_detail_screen.dart) - 탭 구조
```
AppBar
├── Hero Image
├── TabBar [Info | Statistics]
└── TabBarView
    ├── EventDetailInfo (이벤트 정보 + 체크인)
    └── EventStatistics (밴드 통계 + 차트)
```

#### 디자인 특징
- **스와이프 탭**: 정보와 통계를 좌우 스와이프로 전환
- **통계 시각화**: 차트와 지표 카드로 밴드 데이터 표시
- **체크인 시스템**: 라이브 현장에서 인증 가능

### 5. 커뮤니티/뉴스 화면 (news_screen.dart)

#### 레이아웃 구조 (당근마켓 동네생활 패턴)
```
AppBar + TabBar [Community | Official News]
├── TabBarView
    ├── Community Feed (사용자 게시글)
    └── Official Feed (공식 뉴스)
└── FloatingActionButton (글쓰기)
```

#### 글쓰기 화면 (community_post_create_screen.dart)
```
AppBar (+ Post 버튼)
├── Category Dropdown
├── Title Field
├── Content Field (멀티라인)
├── Image Upload Section (추후)
└── Publish Button
```

### 6. 설정 화면 (settings_screen.dart)

#### 레이아웃 구조 (iOS Settings 패턴)
```
AppBar
├── Profile Summary Card
├── Stats Summary  
├── Account Section
│   ├── Edit Profile
│   ├── Privacy & Security
│   └── Verification Management
├── Preferences Section
│   ├── Notifications (Toggle)
│   ├── Dark Mode (Toggle)  
│   └── Language
├── Support Section
└── Account Actions
```

## 공통 컴포넌트 시스템

### KT UXD 컴포넌트 활용

#### 1. KTButton 변형들
- `primary`: 주요 액션 (CTA)
- `secondary`: 보조 액션
- `outline`: 아웃라인 스타일
- `tertiary`: 텍스트 버튼

#### 2. KTCard 변형들  
- `filled`: 채워진 배경
- `outlined`: 테두리만
- `elevated`: 그림자 효과

#### 3. KTTextField 및 KTSearchBar
- 통합된 입력 필드 스타일
- 검색 기능 및 제안 지원

#### 4. KTTopNavigation
- 일관된 앱바 디자인
- 뒷글 버튼 및 액션 버튼 지원

## 네비게이션 플로우

### 메인 플로우
```
MainScreen (5탭)
├── HomeScreen → PlaceDetailScreen / EventDetailScreen  
├── PlaceMapScreen → PlaceDetailScreen
├── EventListScreen → EventDetailScreen
├── NewsScreen → CommunityPostCreateScreen
└── SettingsScreen → 각종 설정 화면들
```

### 딥링크 지원
- `/place/{id}`: 장소 상세
- `/event/{id}`: 이벤트 상세  
- `/post/{id}`: 커뮤니티 게시글

## 상태 관리 전략

### Riverpod 기반 아키텍처
```
UI Layer (Screens/Widgets)
    ↓
ViewModel Layer (Providers)  
    ↓
Repository Layer (Data Sources)
    ↓
Network/Local Storage
```

### 주요 Provider들
- `homeViewModelProvider`: 홈 화면 데이터
- `profileViewModelProvider`: 프로필 및 설정
- `eventViewModelProvider`: 이벤트 데이터
- `stampRallyViewModelProvider`: 스탬프 시스템
- `reviewViewModelProvider`: 리뷰 시스템

## 성능 최적화 고려사항

### 1. 리스트 성능
- `ListView.builder` 사용으로 메모리 효율성
- 이미지 캐싱 및 lazy loading

### 2. 지도 성능  
- 마커 클러스터링 (많은 장소 시)
- 줌 레벨별 마커 밀도 조절

### 3. 상태 관리
- Provider scope 최적화로 불필요한 rebuild 방지
- `Consumer` 위젯으로 선택적 업데이트

## 접근성 (A11y) 고려사항

### 1. Semantic Labels
- 모든 버튼과 액션에 의미있는 라벨
- 이미지에 대한 적절한 alt text

### 2. Focus Management
- 논리적인 포커스 순서
- 키보드 네비게이션 지원

### 3. 색상 대비
- WCAG 2.1 AA 기준 준수
- 다크모드 지원

## 국제화 (i18n) 지원

### 다국어 지원 구조
```
l10n/
├── app_en.arb (영어)
├── app_ko.arb (한국어)  
└── app_ja.arb (일본어 - 추후)
```

### 지역화 고려사항
- 텍스트 길이 변화에 대응하는 유연한 레이아웃
- 날짜/시간 형식의 지역화
- 통화 및 숫자 형식

## 브랜딩 및 시각적 일관성

### KT UXD 색상 시스템
- Primary: KT 브랜드 컬러
- Secondary: 보조 강조색  
- Surface: 카드 및 배경색
- Error/Warning/Success: 상태별 색상

### 타이포그래피 시스템
- Display: 화면 제목용
- Headline: 섹션 제목용
- Title: 카드 제목용
- Body: 본문용
- Label: 라벨 및 캡션용

## 향후 확장 고려사항

### 1. 오프라인 지원
- 지도 타일 캐싱
- 즐겨찾기 장소 로컬 저장

### 2. 소셜 기능 확장
- 친구 시스템
- 그룹 스탬프 랠리

### 3. AR 기능
- 현실 증강으로 장소 정보 오버레이
- 가상 스탬프 수집

이 가이드는 디자인 레퍼런스의 모범 사례들을 종합하여 걸즈밴드 인포 앱만의 일관된 사용자 경험을 만들기 위한 기반을 제공합니다.