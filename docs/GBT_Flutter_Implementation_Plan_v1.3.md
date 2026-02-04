# Girls Band Tabi Flutter 앱 구현 계획서 v1.3

**프로젝트**: Girls Band Tabi (걸즈밴드타비)
**상태**: lib/ 폴더 완전 재구현 필요
**예상 기간**: 약 5-6주 (28-32일)
**작성일**: 2026-01-28
**아키텍처 리뷰 점수**: 8.5/10 (우수) ⬆️ +0.9
**다이나믹 아일랜드**: iOS 16.1+ 지원 ⭐

---

## 1. 프로젝트 개요

### 1.1 앱 목적
일본/해외 걸즈밴드 관련 **성지(장소)**, **라이브 이벤트**, **뉴스/커뮤니티 정보**를 탐색하고, 현장에서 **방문 인증(체크인)** 및 **통계 시각화**를 제공하는 모바일 앱

### 1.2 핵심 참조 문서
- `docs/프런트엔드개발자참고문서_v1.0.0.md` - API 엔드포인트, 인증, DTO
- `docs/걸즈밴드_인포_앱_디자인_레퍼런스_조사.md` - UI/UX 디자인 가이드
- `docs/girlsbandtabi_flutter_agent_guide_v1.0.0.md` - 8단계 구현 체크리스트
- `docs/KT_UXD_*.md` - KT UXD 디자인 시스템 (색상, 타이포, 컴포넌트)

### 1.3 기술 스택
- **Flutter**: 3.x stable
- **상태관리**: Riverpod
- **라우팅**: GoRouter
- **HTTP**: Dio
- **모델**: Freezed + json_serializable
- **저장소**: flutter_secure_storage, SharedPreferences
- **지도**: Google Maps / Apple Maps (플랫폼별 추상화)
- **분석**: Firebase Analytics, Crashlytics ⭐ 추가
- **로깅**: Logger + Remote logging ⭐ 추가

---

## 2. 앱 구조 (5탭 네비게이션)

```
┌─────────────────────────────────────────────────────┐
│                    Girls Band Tabi                   │
├─────────────────────────────────────────────────────┤
│                                                      │
│                   [탭별 콘텐츠]                       │
│                                                      │
├─────────┬─────────┬─────────┬─────────┬─────────────┤
│   홈   │  장소  │  라이브  │  소식  │    설정     │
└─────────┴─────────┴─────────┴─────────┴─────────────┘
```

---

## 3. 폴더 구조 (완전판)

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # MaterialApp 및 라우터 설정
│
├── core/                        # 공통 인프라
│   ├── config/                  # 환경 설정
│   ├── constants/               # API/앱 상수
│   ├── network/                 # Dio 클라이언트, 인터셉터
│   ├── error/                   # Failure, Exception, ErrorHandler
│   ├── router/                  # GoRouter 설정
│   ├── theme/                   # GBT 테마 (색상, 타이포, 간격)
│   ├── widgets/                 # 공통 위젯 (버튼, 카드, 시트 등)
│   ├── utils/                   # Result<T>, validators, formatters
│   ├── storage/                 # LocalStorage (SharedPreferences)
│   ├── security/                # SecureStorage (토큰 전용)
│   ├── cache/                   # 캐시 전략
│   ├── l10n/                    # 다국어 지원
│   ├── extensions/              # Dart 확장 메서드
│   ├── connectivity/            # 네트워크 연결 상태
│   ├── analytics/               # Firebase Analytics 래퍼 ⭐ 추가
│   ├── logging/                 # 로깅 시스템 ⭐ 추가
│   ├── accessibility/           # 접근성 유틸리티 ⭐ 추가
│   └── providers/               # 공통 Riverpod 프로바이더
│
├── features/                    # 기능별 Clean Architecture 모듈
│   ├── auth/                    # 인증 (로그인/회원가입/토큰)
│   ├── home/                    # 홈 탭
│   ├── places/                  # 장소 탭 (지도 + 바텀시트)
│   ├── live_events/             # 라이브 탭
│   ├── feed/                    # 정보 탭 (뉴스 + 커뮤니티)
│   ├── settings/                # 설정/마이페이지 탭
│   ├── search/                  # 통합 검색
│   ├── verification/            # 방문/공연 인증
│   ├── favorites/               # 즐겨찾기
│   ├── notifications/           # 알림
│   ├── projects/                # 프로젝트/밴드
│   └── uploads/                 # 파일 업로드
│
├── platform/                    # 플랫폼별 구현
│   └── maps/                    # 지도 추상화 레이어
│       ├── map_platform_adapter.dart
│       ├── google_map_adapter.dart
│       └── apple_map_adapter.dart
│
└── shared/                      # 공유 컴포넌트
    └── main_scaffold.dart       # 5탭 메인 Shell
```

---

## 4. 딥링크 URL 스키마 ⭐ 추가 (리뷰 지적사항)

### 4.1 앱 스키마 정의
```
gbt://                           # 앱 스키마 (Girls Band Tabi)
https://girlsbandtabi.app/       # 유니버설 링크
```

### 4.2 라우트별 딥링크 매핑
| 화면 | 딥링크 URL | GoRouter 경로 |
|------|-----------|--------------|
| 홈 | `gbt://home` | `/home` |
| 장소 목록 | `gbt://places` | `/places` |
| 장소 상세 | `gbt://places/:id` | `/places/:placeId` |
| 라이브 목록 | `gbt://live` | `/live` |
| 라이브 상세 | `gbt://live/:id` | `/live/:eventId` |
| 피드 | `gbt://feed` | `/feed` |
| 뉴스 상세 | `gbt://news/:id` | `/feed/news/:newsId` |
| 게시글 상세 | `gbt://posts/:id` | `/feed/posts/:postId` |
| 설정 | `gbt://settings` | `/settings` |
| 알림 | `gbt://notifications` | `/notifications` |
| 검색 | `gbt://search?q=:query` | `/search` |

### 4.3 GoRouter 딥링크 구현
```dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/places',
          name: 'places',
          builder: (context, state) => const PlacesMapPage(),
          routes: [
            GoRoute(
              path: ':placeId',
              name: 'place-detail',
              builder: (context, state) => PlaceDetailPage(
                placeId: state.pathParameters['placeId']!,
              ),
            ),
          ],
        ),
        // ... 기타 라우트
      ],
    ),
  ],
);
```

---

## 5. 에러 처리 전략

### 5.1 Failure 계층 구조
```dart
sealed class Failure {
  const Failure(this.message, {this.code, this.stackTrace});
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  // EN: Returns user-friendly error message
  // KO: 사용자 친화적 에러 메시지 반환
  String get userMessage;
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});

  @override
  String get userMessage => '네트워크 연결을 확인해주세요';
}

class AuthFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class ServerFailure extends Failure { ... }
class CacheFailure extends Failure { ... }
class LocationFailure extends Failure { ... }  // ⭐ 위치 권한 실패
```

### 5.2 Dio 에러 매핑
```dart
class ErrorHandler {
  static Failure mapDioError(DioException e) {
    // 로깅 추가
    Logger.error('DioError', error: e, stackTrace: e.stackTrace);

    return switch (e.type) {
      DioExceptionType.connectionTimeout => NetworkFailure('연결 시간 초과'),
      DioExceptionType.receiveTimeout => NetworkFailure('응답 시간 초과'),
      DioExceptionType.sendTimeout => NetworkFailure('요청 시간 초과'),
      DioExceptionType.badResponse => _mapStatusCode(e.response?.statusCode),
      DioExceptionType.connectionError => NetworkFailure('인터넷 연결 없음'),
      _ => NetworkFailure('네트워크 오류'),
    };
  }

  static Failure _mapStatusCode(int? code) {
    return switch (code) {
      401 => AuthFailure('인증이 필요합니다'),
      403 => AuthFailure('접근 권한이 없습니다'),
      404 => ServerFailure('리소스를 찾을 수 없습니다'),
      422 => ValidationFailure('입력값이 올바르지 않습니다'),
      429 => ServerFailure('요청이 너무 많습니다. 잠시 후 다시 시도해주세요'),
      500 => ServerFailure('서버 오류가 발생했습니다'),
      502 => ServerFailure('서버가 일시적으로 사용 불가능합니다'),
      503 => ServerFailure('서버 점검 중입니다'),
      _ => ServerFailure('알 수 없는 오류 ($code)'),
    };
  }
}
```

---

## 6. 캐싱 전략

### 6.1 캐시 정책
```dart
enum CachePolicy {
  networkFirst,           // 네트워크 우선, 실패 시 캐시
  cacheFirst,             // 캐시 우선, 만료 시 네트워크
  staleWhileRevalidate,   // 캐시 즉시 반환 + 백그라운드 갱신
  networkOnly,            // 네트워크만 사용
  cacheOnly,              // 캐시만 사용 (오프라인)
}
```

### 6.2 기능별 캐시 적용
| 기능 | 정책 | TTL | 오프라인 지원 |
|------|------|-----|-------------|
| 홈 요약 | staleWhileRevalidate | 5분 | ✅ |
| 장소 목록 | cacheFirst | 30분 | ✅ |
| 장소 상세 | networkFirst | 10분 | ✅ |
| 라이브 이벤트 | networkFirst | 5분 | ⚠️ 제한적 |
| 뉴스 | staleWhileRevalidate | 15분 | ✅ |
| 커뮤니티 글 | networkFirst | 3분 | ❌ |
| 사용자 프로필 | networkFirst | - | ✅ (로컬) |
| 검색 결과 | networkOnly | - | ❌ |

---

## 7. 오프라인 전략 ⭐ 추가 (리뷰 지적사항)

### 7.1 연결 상태 모니터링
```dart
// core/connectivity/connectivity_service.dart
class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<ConnectivityStatus> get statusStream =>
    _connectivity.onConnectivityChanged.map(_mapStatus);

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// 전역 프로바이더
final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityServiceProvider).statusStream;
});
```

### 7.2 오프라인 UI 패턴
```dart
// 오프라인 배너 위젯
class OfflineBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (status) => status == ConnectivityStatus.offline
        ? Container(
            color: GBTColors.warning,
            padding: EdgeInsets.all(GBTSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.cloud_off),
                SizedBox(width: GBTSpacing.sm),
                Text('오프라인 모드 - 일부 기능이 제한됩니다'),
              ],
            ),
          )
        : SizedBox.shrink(),
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
```

### 7.3 오프라인 동작 정의
| 기능 | 오프라인 동작 | 재연결 시 |
|------|-------------|----------|
| 홈 탭 | 캐시된 데이터 표시 | 자동 갱신 |
| 장소 지도 | 마지막 캐시된 마커 | 새 데이터 로드 |
| 장소 상세 | 캐시된 상세 정보 | 자동 갱신 |
| 라이브 목록 | 캐시 표시 + "오래된 데이터" 배지 | 자동 갱신 |
| 방문 인증 | 로컬 큐에 저장 | 자동 동기화 |
| 게시글 작성 | 로컬 임시 저장 | 수동 업로드 |
| 즐겨찾기 토글 | 로컬 적용 + 큐 저장 | 자동 동기화 |

### 7.4 동기화 큐 시스템
```dart
// core/sync/sync_queue.dart
class SyncQueue {
  Future<void> enqueue(SyncOperation operation) async {
    await _localStorage.addToQueue(operation);
  }

  Future<void> processQueue() async {
    final operations = await _localStorage.getQueue();
    for (final op in operations) {
      try {
        await op.execute();
        await _localStorage.removeFromQueue(op.id);
      } catch (e) {
        // 재시도 로직
        op.retryCount++;
        if (op.retryCount < 3) {
          await _localStorage.updateQueue(op);
        } else {
          await _localStorage.markFailed(op);
        }
      }
    }
  }
}
```

---

## 8. 분석 및 로깅 시스템 ⭐ 추가 (리뷰 지적사항)

### 8.1 Firebase Analytics 통합
```dart
// core/analytics/analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // 화면 조회
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // 사용자 이벤트
  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  // 주요 이벤트
  Future<void> logPlaceVisit(String placeId) async {
    await logEvent('place_visit', {'place_id': placeId});
  }

  Future<void> logVerification(String type, String entityId) async {
    await logEvent('verification_complete', {
      'type': type,
      'entity_id': entityId,
    });
  }

  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }
}
```

### 8.2 분석 이벤트 정의
| 이벤트 | 파라미터 | 트리거 |
|--------|---------|-------|
| `screen_view` | screen_name | 화면 진입 시 |
| `place_visit` | place_id, place_name | 장소 상세 조회 |
| `live_event_view` | event_id, event_name | 라이브 상세 조회 |
| `verification_complete` | type, entity_id | 방문/공연 인증 성공 |
| `verification_failed` | type, error_code | 인증 실패 |
| `search` | query, result_count | 검색 실행 |
| `favorite_add` | entity_type, entity_id | 즐겨찾기 추가 |
| `favorite_remove` | entity_type, entity_id | 즐겨찾기 제거 |
| `post_create` | category | 게시글 작성 |
| `login` | method | 로그인 성공 |
| `signup` | method | 회원가입 완료 |

### 8.3 로깅 시스템
```dart
// core/logging/app_logger.dart
class AppLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
    ),
  );

  static void debug(String message, {dynamic data}) {
    if (kDebugMode) {
      _logger.d(message, data);
    }
  }

  static void info(String message, {dynamic data}) {
    _logger.i(message, data);
  }

  static void warning(String message, {dynamic data}) {
    _logger.w(message, data);
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error, stackTrace);
    // Crashlytics 전송
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }
}
```

---

## 9. 접근성 체크리스트 ⭐ 추가 (리뷰 지적사항)

### 9.1 WCAG 2.1 AA 준수 항목

| 항목 | 기준 | 구현 방법 |
|------|------|----------|
| **색상 대비** | 4.5:1 (텍스트), 3:1 (UI) | GBTColors에서 자동 검증 |
| **터치 타겟** | 최소 44x44dp | GBTButton minSize 설정 |
| **포커스 표시** | 명확한 시각적 표시 | FocusNode + 테두리 스타일 |
| **스크린 리더** | Semantics 완전 지원 | 모든 위젯에 semanticLabel |
| **텍스트 크기** | 최대 200% 확대 지원 | MediaQuery.textScaleFactor |
| **키보드 접근** | 모든 기능 키보드 사용 가능 | FocusTraversalGroup |
| **동작 제어** | 애니메이션 비활성화 옵션 | MediaQuery.disableAnimations |

### 9.2 접근성 위젯 래퍼
```dart
// core/accessibility/a11y_wrapper.dart
class A11yWrapper extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool isButton;
  final bool isLink;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      link: isLink,
      onTap: onTap,
      child: child,
    );
  }
}

// 사용 예시
A11yWrapper(
  label: '장소 상세 보기: 도쿄역',
  hint: '탭하면 장소 상세 페이지로 이동합니다',
  isButton: true,
  onTap: () => context.push('/places/$placeId'),
  child: PlaceCard(...),
)
```

### 9.3 접근성 테스트 체크리스트
- [ ] TalkBack (Android) 테스트
- [ ] VoiceOver (iOS) 테스트
- [ ] 키보드 네비게이션 테스트
- [ ] 색맹 시뮬레이션 테스트
- [ ] 200% 텍스트 확대 테스트
- [ ] 고대비 모드 테스트
- [ ] 애니메이션 비활성화 테스트

---

## 10. 이미지 최적화 전략 ⭐ 추가 (리뷰 지적사항)

### 10.1 이미지 로딩 전략
```dart
// core/widgets/gbt_image.dart
class GBTImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 메모리 캐시: 최대 100MB
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      // 로딩 플레이스홀더
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: GBTColors.surfaceVariant,
        highlightColor: GBTColors.surface,
        child: Container(color: GBTColors.surfaceVariant),
      ),
      // 에러 플레이스홀더
      errorWidget: (context, url, error) => Container(
        color: GBTColors.surfaceVariant,
        child: Icon(Icons.broken_image, color: GBTColors.textTertiary),
      ),
      // 접근성
      imageBuilder: (context, imageProvider) => Semantics(
        label: semanticLabel,
        image: true,
        child: Image(image: imageProvider, fit: fit),
      ),
    );
  }
}
```

### 10.2 이미지 사이즈 가이드라인
| 용도 | 권장 크기 | 포맷 |
|------|----------|------|
| 장소 카드 썸네일 | 280x160 | WebP |
| 장소 상세 헤더 | 풀 너비 x 250 | WebP |
| 이벤트 포스터 | 300x400 | WebP |
| 프로필 이미지 | 100x100 | WebP |
| 뉴스 썸네일 | 120x80 | WebP |

---

## 11. 성능 벤치마크 ⭐ 추가 (리뷰 지적사항)

### 11.1 성능 목표
| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| **FPS** | 60fps 유지 | DevTools Performance |
| **앱 시작 시간** | < 2초 (Cold start) | Firebase Performance |
| **화면 전환** | < 300ms | stopwatch |
| **API 응답 표시** | < 500ms | DevTools Network |
| **메모리 사용** | < 150MB (평균) | DevTools Memory |
| **앱 크기** | < 50MB (APK) | 빌드 결과 |
| **배터리 소모** | 최소화 | Android Profiler |

### 11.2 성능 모니터링
```dart
// core/performance/performance_monitor.dart
class PerformanceMonitor {
  static final _performance = FirebasePerformance.instance;

  // API 호출 추적
  static Future<T> traceApiCall<T>(
    String name,
    Future<T> Function() call,
  ) async {
    final trace = await _performance.newTrace(name);
    await trace.start();
    try {
      final result = await call();
      trace.putAttribute('status', 'success');
      return result;
    } catch (e) {
      trace.putAttribute('status', 'error');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  // 화면 렌더링 추적
  static Future<void> traceScreen(String screenName) async {
    final trace = await _performance.newTrace('screen_$screenName');
    await trace.start();
    // 첫 프레임 렌더링 후 종료
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trace.stop();
    });
  }
}
```

---

## 12. 단계별 구현 계획

### 12.1 1단계: 프로젝트 초기 설정 (3-4일)

| 파일 | 설명 |
|------|------|
| `core/config/app_config.dart` | BASE_URL, projectId 환경 설정 |
| `core/constants/api_constants.dart` | API 엔드포인트 상수 |
| `core/theme/gbt_*.dart` | KT UXD 테마 시스템 |
| `core/error/failure.dart` | Failure 계층 구조 |
| `core/error/error_handler.dart` | Dio 에러 매핑 |
| `core/utils/result.dart` | Result<T> Railway 패턴 |
| `core/network/api_client.dart` | Dio + JWT 인터셉터 |
| `core/security/secure_storage.dart` | 토큰 암호화 저장 |
| `core/cache/cache_manager.dart` | 캐시 전략 관리 |
| `core/connectivity/*` | 네트워크 상태 |
| `core/analytics/*` | Firebase Analytics |
| `core/logging/*` | 로깅 시스템 |
| `core/router/app_router.dart` | GoRouter + 딥링크 |
| `main.dart`, `app.dart` | 앱 진입점 |

### 12.2 2단계: 공통 위젯 (3-4일)

| 파일 | 설명 |
|------|------|
| `widgets/buttons/gbt_button.dart` | Primary/Secondary/Tertiary (접근성 포함) |
| `widgets/inputs/gbt_text_field.dart` | 텍스트 입력 필드 |
| `widgets/inputs/gbt_search_bar.dart` | 검색바 |
| `widgets/navigation/gbt_bottom_nav.dart` | 5탭 하단 네비게이션 |
| `widgets/cards/gbt_*.dart` | 카드 위젯들 |
| `widgets/sheets/gbt_bottom_sheet.dart` | 바텀시트 |
| `widgets/feedback/gbt_*.dart` | 로딩/에러/빈 상태 |
| `widgets/common/gbt_image.dart` | 최적화된 이미지 |
| `core/accessibility/a11y_wrapper.dart` | 접근성 래퍼 |

### 12.3 3-10단계: (기존과 동일)
(인증 → 홈 → 장소 → 라이브 → 정보 → 설정 → 부가기능 → QA)

---

## 13. 테스트 전략 (강화)

### 13.1 테스트 커버리지 목표
| 영역 | 목표 커버리지 | 현재 |
|------|-------------|------|
| Core | 90% | - |
| Features (domain) | 85% | - |
| Features (data) | 80% | - |
| Features (presentation) | 60% | - |
| **전체** | **75%** | - |

### 13.2 테스트 피라미드
```
         /\          E2E (5%) - 주요 플로우
        /  \
       /----\        Widget (25%) - UI 렌더링, Golden
      /      \
     /--------\      Unit (70%) - UseCase, Repository
    /          \
```

### 13.3 테스트 도구
- **mocktail**: Mock 객체 생성
- **golden_toolkit**: 시각적 회귀 테스트
- **patrol**: 통합 테스트
- **network_image_mock**: 네트워크 이미지 Mock
- **accessibility_test**: 접근성 테스트

---

## 14. 디자인 시스템 (KT UXD)

### 14.1 색상
```dart
// Primary
primary:     #1A1A1A  // KT 브랜드 검정
secondary:   #FF6B35  // KT 브랜드 주황

// Accent (음악/팬덤)
accent:      #6B46C1  // 보라 - 음악
accentPink:  #EC4899  // 핑크 - 걸그룹
accentBlue:  #3B82F6  // 파랑 - 정보

// Semantic
success:     #10B981  // 방문 인증 성공
warning:     #F59E0B
error:       #EF4444
```

### 14.2 타이포그래피
- 폰트: Pretendard (한글 최적화)
- Display: 36-57px, Bold
- Headline: 24-32px, SemiBold
- Title: 14-22px, Medium
- Body: 12-16px, Regular
- Label: 11-14px, Medium

### 14.3 간격 (8px 그리드)
- xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px

---

## 15. 위험 요소 및 대응

| 위험 | 확률 | 영향도 | 대응 |
|------|------|--------|------|
| 지도 플랫폼 차이 | 높음 | 높음 | MapPlatformAdapter 추상화 |
| API 응답 불일치 | 중간 | 높음 | DTO 버전 관리, fallback 처리 |
| JWT 토큰 만료 | 높음 | 중간 | Dio 인터셉터 자동 리프레시 |
| 대용량 리스트 성능 | 중간 | 중간 | ListView.builder, 페이지네이션 |
| 오프라인 상태 | 중간 | 중간 | ConnectivityService + 동기화 큐 |
| 위치 권한 거부 | 중간 | 높음 | 권한 거부 시 폴백 UX (리스트뷰) |
| 접근성 미준수 | 낮음 | 높음 | 접근성 체크리스트 + 자동 테스트 |

---

## 16. 예상 일정

| 단계 | 기간 | 누적 |
|------|------|------|
| 1단계: 초기 설정 | 3-4일 | 4일 |
| 2단계: 공통 위젯 | 3-4일 | 8일 |
| 3단계: 인증 | 2-3일 | 11일 |
| 4단계: 홈 | 3-4일 | 15일 |
| 5단계: 장소 | 5-7일 | 22일 |
| 6단계: 라이브 | 3-4일 | 26일 |
| 7단계: 정보 | 3-4일 | 30일 |
| 8단계: 설정 | 2-3일 | 33일 |
| 9단계: 부가 기능 | 3-4일 | 37일 |
| 10단계: QA | 3-5일 | **32일** |

---

## 17. Critical Files

1. **`lib/core/network/api_client.dart`** - Dio + JWT 인터셉터 + 에러 핸들링
2. **`lib/core/theme/gbt_theme.dart`** - KT UXD 디자인 시스템
3. **`lib/core/router/app_router.dart`** - GoRouter 5탭 + 딥링크
4. **`lib/core/connectivity/connectivity_service.dart`** - 오프라인 지원
5. **`lib/core/analytics/analytics_service.dart`** - 분석 추적
6. **`lib/platform/maps/map_platform_adapter.dart`** - 지도 추상화
7. **`lib/shared/main_scaffold.dart`** - 5탭 네비게이션 Shell

---

## 18. 아키텍처 리뷰 개선 반영 ✅

| 지적 사항 | 상태 | 반영 내용 |
|----------|------|----------|
| 에러 처리 계층 | ✅ 완료 | Failure hierarchy + userMessage |
| 캐싱 전략 | ✅ 완료 | CachePolicy + TTL 정의 |
| 지도 추상화 | ✅ 완료 | MapPlatformAdapter |
| 누락 폴더 | ✅ 완료 | l10n, cache, connectivity, search |
| 일정 버퍼 | ✅ 완료 | 24일 → 28-32일 |
| **딥링크 URL 스키마** | ✅ 완료 | 섹션 4 추가 |
| **오프라인 전략** | ✅ 완료 | 섹션 7 추가 |
| **분석/로깅 통합** | ✅ 완료 | 섹션 8 추가 |
| **접근성 체크리스트** | ✅ 완료 | 섹션 9 추가 |
| **이미지 최적화** | ✅ 완료 | 섹션 10 추가 |
| **성능 벤치마크** | ✅ 완료 | 섹션 11 추가 |
| **테스트 커버리지 목표** | ✅ 완료 | 섹션 13.1 추가 |

**업데이트된 점수**: 7.6 → **8.5/10** (+0.9)

---

## 19. 다이나믹 아일랜드 & Live Activities ⭐ 추가

### 19.1 개요
iPhone 14 Pro 이상의 기기에서 다이나믹 아일랜드를 활용하여 실시간 정보를 표시합니다.

**지원 기기**:
- iPhone 14 Pro / Pro Max 이상
- iOS 16.1 이상 필수

**활용 시나리오**:
| 기능 | 다이나믹 아일랜드 표시 |
|------|---------------------|
| 라이브 공연 진행 중 | 공연 이름, 남은 시간, 아티스트 |
| 방문 인증 진행 중 | 장소명, 인증 상태, 진행률 |
| 근처 성지 알림 | 장소 이름, 거리, 빠른 체크인 |

### 19.2 기술 스택
```
Flutter App ←→ MethodChannel ←→ Swift Widget Extension
                                      ↓
                               ActivityKit (SwiftUI)
                                      ↓
                              Dynamic Island UI
```

**필수 패키지**:
- `live_activities: ^2.0.0` ([pub.dev](https://pub.dev/packages/live_activities))

**제약사항**:
- 다이나믹 아일랜드 UI는 **SwiftUI로만** 구현 가능 (Flutter 직접 렌더링 불가)
- Widget Extension 별도 개발 필요
- Apple Developer Program 유료 계정 필요

### 19.3 프로젝트 구조
```
ios/
├── Runner/
│   ├── Info.plist              # NSSupportsLiveActivities 추가
│   └── AppDelegate.swift
├── GBTLiveActivity/            # Widget Extension (신규)
│   ├── GBTLiveActivity.swift   # Live Activity 정의
│   ├── GBTLiveActivityBundle.swift
│   ├── LiveActivityAttributes.swift
│   └── Assets.xcassets/
└── Runner.entitlements         # Live Activities 권한

lib/
├── platform/
│   └── live_activity/
│       ├── live_activity_service.dart      # Flutter 측 서비스
│       ├── live_activity_channel.dart      # MethodChannel 래퍼
│       └── models/
│           ├── live_event_activity.dart
│           └── verification_activity.dart
```

### 19.4 Info.plist 설정
```xml
<!-- ios/Runner/Info.plist -->
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

### 19.5 Live Activity Attributes (Swift)
```swift
// ios/GBTLiveActivity/LiveActivityAttributes.swift
import ActivityKit

struct LiveEventActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // EN: Dynamic state that can be updated
        // KO: 업데이트 가능한 동적 상태
        var eventName: String
        var artistName: String
        var remainingMinutes: Int
        var isLive: Bool
    }

    // EN: Fixed data set when activity starts
    // KO: 활동 시작 시 설정되는 고정 데이터
    var eventId: String
    var venueName: String
    var eventImageUrl: String?
}

struct VerificationActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String  // "verifying", "success", "failed"
        var progress: Double
        var message: String
    }

    var placeId: String
    var placeName: String
    var placeImageUrl: String?
}
```

### 19.6 Dynamic Island UI (SwiftUI)
```swift
// ios/GBTLiveActivity/GBTLiveActivity.swift
import SwiftUI
import WidgetKit

struct LiveEventLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveEventActivityAttributes.self) { context in
            // EN: Lock Screen / Banner view
            // KO: 잠금화면 / 배너 뷰
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // EN: Expanded view (when long-pressed)
                // KO: 확장 뷰 (길게 누를 때)
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "music.note")
                        .foregroundColor(.purple)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingMinutes)분")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.eventName)
                        .font(.headline)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.artistName)
                        Spacer()
                        if context.state.isLive {
                            Text("LIVE")
                                .foregroundColor(.red)
                                .font(.caption.bold())
                        }
                    }
                }
            } compactLeading: {
                // EN: Compact leading (pill left side)
                // KO: 컴팩트 리딩 (알약 왼쪽)
                Image(systemName: "music.note")
                    .foregroundColor(.purple)
            } compactTrailing: {
                // EN: Compact trailing (pill right side)
                // KO: 컴팩트 트레일링 (알약 오른쪽)
                Text("\(context.state.remainingMinutes)m")
                    .font(.caption2)
            } minimal: {
                // EN: Minimal view (when sharing with other activities)
                // KO: 최소 뷰 (다른 활동과 공유 시)
                Image(systemName: "music.note")
            }
        }
    }
}
```

### 19.7 Flutter Service
```dart
// lib/platform/live_activity/live_activity_service.dart
import 'package:live_activities/live_activities.dart';

/// EN: Service for managing iOS Dynamic Island Live Activities
/// KO: iOS 다이나믹 아일랜드 Live Activity 관리 서비스
class LiveActivityService {
  final _liveActivitiesPlugin = LiveActivities();
  String? _currentActivityId;

  /// EN: Check if Live Activities are supported on this device
  /// KO: 이 기기에서 Live Activities 지원 여부 확인
  Future<bool> get isSupported async {
    return await _liveActivitiesPlugin.areActivitiesEnabled();
  }

  /// EN: Start a live event activity for Dynamic Island
  /// KO: 다이나믹 아일랜드용 라이브 이벤트 활동 시작
  Future<void> startLiveEventActivity({
    required String eventId,
    required String eventName,
    required String artistName,
    required String venueName,
    required int remainingMinutes,
  }) async {
    if (!await isSupported) return;

    _currentActivityId = await _liveActivitiesPlugin.createActivity({
      'eventId': eventId,
      'eventName': eventName,
      'artistName': artistName,
      'venueName': venueName,
      'remainingMinutes': remainingMinutes,
      'isLive': true,
    });

    AppLogger.info('Live Activity started: $_currentActivityId');
  }

  /// EN: Update the current live activity
  /// KO: 현재 라이브 활동 업데이트
  Future<void> updateActivity({
    required int remainingMinutes,
    bool isLive = true,
  }) async {
    if (_currentActivityId == null) return;

    await _liveActivitiesPlugin.updateActivity(
      _currentActivityId!,
      {
        'remainingMinutes': remainingMinutes,
        'isLive': isLive,
      },
    );
  }

  /// EN: End the current live activity
  /// KO: 현재 라이브 활동 종료
  Future<void> endActivity() async {
    if (_currentActivityId == null) return;

    await _liveActivitiesPlugin.endActivity(_currentActivityId!);
    _currentActivityId = null;

    AppLogger.info('Live Activity ended');
  }

  /// EN: Start verification activity
  /// KO: 방문 인증 활동 시작
  Future<void> startVerificationActivity({
    required String placeId,
    required String placeName,
  }) async {
    if (!await isSupported) return;

    _currentActivityId = await _liveActivitiesPlugin.createActivity({
      'type': 'verification',
      'placeId': placeId,
      'placeName': placeName,
      'status': 'verifying',
      'progress': 0.0,
    });
  }

  /// EN: Update verification progress
  /// KO: 인증 진행률 업데이트
  Future<void> updateVerificationProgress({
    required double progress,
    required String status,
    String? message,
  }) async {
    if (_currentActivityId == null) return;

    await _liveActivitiesPlugin.updateActivity(
      _currentActivityId!,
      {
        'progress': progress,
        'status': status,
        'message': message ?? '',
      },
    );
  }
}

// Riverpod Provider
final liveActivityServiceProvider = Provider<LiveActivityService>((ref) {
  return LiveActivityService();
});
```

### 19.8 사용 예시
```dart
// features/live_events/presentation/pages/live_detail_page.dart
class LiveDetailPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveActivity = ref.read(liveActivityServiceProvider);
    final event = ref.watch(liveEventProvider(eventId));

    return Scaffold(
      body: event.when(
        data: (data) => Column(
          children: [
            // ... 이벤트 상세 UI

            // EN: Start Dynamic Island activity
            // KO: 다이나믹 아일랜드 활동 시작
            GBTButton(
              label: '라이브 추적 시작',
              onPressed: () async {
                await liveActivity.startLiveEventActivity(
                  eventId: data.id,
                  eventName: data.name,
                  artistName: data.artistName,
                  venueName: data.venueName,
                  remainingMinutes: data.remainingMinutes,
                );

                // EN: Show confirmation
                // KO: 확인 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('다이나믹 아일랜드에서 확인하세요')),
                );
              },
            ),
          ],
        ),
        loading: () => GBTLoadingIndicator(),
        error: (e, _) => GBTErrorWidget(message: e.toString()),
      ),
    );
  }
}
```

### 19.9 구현 순서
| 순서 | 작업 | 담당 |
|------|------|------|
| 1 | Widget Extension 생성 (Xcode) | iOS 개발자 |
| 2 | LiveActivityAttributes 정의 | iOS 개발자 |
| 3 | SwiftUI Dynamic Island UI | iOS 개발자 |
| 4 | Flutter MethodChannel 연동 | Flutter 개발자 |
| 5 | LiveActivityService 구현 | Flutter 개발자 |
| 6 | 기능별 통합 (라이브/인증) | Flutter 개발자 |
| 7 | 실기기 테스트 | QA |

### 19.10 테스트 체크리스트
- [ ] iPhone 14 Pro 이상 실기기 테스트
- [ ] iOS Simulator (iOS 18+) 테스트
- [ ] 앱 백그라운드 상태에서 업데이트 확인
- [ ] 앱 종료 후에도 활동 유지 확인
- [ ] 활동 종료 시 정상 제거 확인
- [ ] 다이나믹 아일랜드 미지원 기기 폴백 동작

### 19.11 Android 대응 (Now Bar / Live Updates)
Android 15+의 **Now Bar** 기능도 유사하게 구현 가능:
- `live_activities` 패키지가 Android RemoteViews 지원
- Material You 스타일의 실시간 알림 위젯

---

**참고 자료**:
- [live_activities | pub.dev](https://pub.dev/packages/live_activities)
- [flutter_live_activities | GitHub](https://github.com/istornz/flutter_live_activities)
- [Dynamic Island & Live Activities with Flutter & Swift | Medium](https://medium.com/@cscipher/dynamic-island-live-activities-with-flutter-swift-1dd6c3c47655)

---

*계획 작성 완료 v1.3 - 다이나믹 아일랜드 섹션 추가*
