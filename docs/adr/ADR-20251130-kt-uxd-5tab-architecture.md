# ADR-20251130: KT UXD 5탭 구조 앱 아키텍처 설계

## Status
Accepted

## Context

### 요구사항
- PDF 가이드라인 기반 5탭 구조: 홈/장소/라이브/정보/설정
- Clean Architecture + Feature-first 구조 적용
- Riverpod 상태 관리 활용
- 기존 KT 디자인 시스템 연동

### PDF 가이드라인 분석
#### 홈 탭 (Home)
- 카드형 콘텐츠 피드
- 다양한 섹션별 요약 정보 (다가오는 라이브, 인기 장소, 최신 뉴스)
- 치지직 앱의 홈 피드 구조 참고

#### 장소 탭 (Places) 
- 지도 + 바텀시트 패턴
- Airbnb, 네이버 지도 UI 참고
- 장소 리스트 및 상세 정보
- 방문 인증 CTA 버튼

#### 라이브 탭 (Live)
- 공연/라이브 이벤트 목록
- 카드형 리스트 UI
- 라이브 상세 + 방문 인증
- 밴드별 통계 화면 (스와이프)

#### 정보 탭 (Info) → "소식" 제안
- 커뮤니티 & 뉴스 피드
- 사용자 게시글 + 공식 뉴스 혼합
- 당근마켓 동네생활 탭 참고

#### 설정 탭 (Settings)
- 전형적인 설정 리스트 UI
- 계정 관리, 알림 설정, 앱 환경 설정
- 마이페이지 연계 고려

## Decision

### 1. 디렉토리 구조
```
lib/
├── main.dart                     # 앱 진입점
├── app.dart                      # MaterialApp 설정
├── core/                         # 공통 인프라
│   ├── config/                   # 앱 설정
│   ├── constants/                # 상수 정의
│   ├── error/                    # 에러 처리
│   ├── network/                  # 네트워크 클라이언트
│   ├── router/                   # 라우팅 설정
│   ├── theme/                    # KT 디자인 시스템
│   ├── utils/                    # 유틸리티
│   └── widgets/                  # 공통 위젯
├── features/                     # Feature 모듈
│   ├── home/                     # 홈 탭
│   ├── places/                   # 장소 탭
│   ├── live_events/              # 라이브 탭
│   ├── news/                     # 소식 탭 (정보→소식)
│   ├── settings/                 # 설정 탭
│   ├── auth/                     # 인증 (기존)
│   └── profile/                  # 프로필 (기존)
└── shared/                       # 공유 리소스
```

### 2. 각 Feature 내부 구조
```
features/<feature>/
├── presentation/                 # UI 레이어
│   ├── pages/                    # 화면
│   ├── widgets/                  # 위젯
│   └── controllers/              # 상태 관리
├── application/                  # 애플리케이션 레이어
│   ├── usecases/                 # 비즈니스 로직
│   ├── providers/                # Riverpod 프로바이더
│   └── controllers/              # 컨트롤러
├── domain/                       # 도메인 레이어
│   ├── entities/                 # 엔티티
│   ├── repositories/             # 레포지토리 인터페이스
│   └── usecases/                 # 유스케이스
└── data/                         # 데이터 레이어
    ├── models/                   # 데이터 모델
    ├── datasources/              # 데이터 소스
    └── repositories/             # 레포지토리 구현
```

### 3. 5탭 네비게이션 구조
- StatefulShellRoute.indexedStack 사용
- 각 탭별 독립적인 네비게이션 스택
- KT UXD 디자인 시스템 적용

### 4. 탭별 주요 기능
#### 홈 탭
- 카드형 피드 UI (KTFeedCard)
- 섹션별 요약 정보
- 다가오는 라이브, 인기 장소, 최신 소식

#### 장소 탭  
- 지도 기반 UI + 바텀시트
- 장소 리스트 카드
- 장소 상세 + 방문 인증
- 방문 통계 시각화

#### 라이브 탭
- 라이브 이벤트 카드 리스트
- 라이브 상세 정보
- 밴드별 통계 (스와이프 네비게이션)

#### 소식 탭 (정보 → 소식)
- 커뮤니티 + 뉴스 피드
- 사용자 게시글 + 공식 뉴스
- 글쓰기 플로팅 액션 버튼

#### 설정 탭
- 설정 메뉴 리스트
- 계정 관리, 알림 설정
- 마이페이지 요소 포함

## Consequences

### 장점
- PDF 가이드라인과 완전히 일치하는 구조
- Clean Architecture로 유지보수성 확보
- Feature-first로 팀 협업 효율성 증대
- 기존 KT 디자인 시스템 활용

### 단점
- 초기 설정 복잡도 증가
- Feature 간 의존성 관리 필요

### 마이그레이션 계획
1. 기존 screens/ → features/*/presentation/pages/ 이동
2. 각 feature별 domain/application 레이어 구축
3. 5탭 네비게이션 구조로 라우터 변경
4. KT UXD 컴포넌트 통합

---

**작성자**: Claude (mobile-app-developer)  
**작성일**: 2024-11-30  
**관련 문서**: PDF 디자인 레퍼런스 조사, AGENTS.md
