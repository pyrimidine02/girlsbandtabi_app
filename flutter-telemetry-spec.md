# Flutter 앱 텔레메트리 연동 명세서

> 작성일: 2026-03-20  
> 대상: Flutter 앱팀  
> 서버 담당: 백엔드팀

---

## 1. 개요

서버는 아래 3가지 목적을 위한 텔레메트리 수집 인프라를 구축했습니다.

| 목적 | 설명 |
|------|------|
| **기기 지문 (Device Fingerprint)** | 하드웨어 기반 식별자로 밴 기기 차단 |
| **클라이언트 이벤트** | GPS 위변조·텔레포트 등 어뷰징 신호 수집 |
| **Sentry 크래시 리포팅** | 앱 크래시 / Unhandled Exception 추적 |

앱팀이 구현해야 할 항목은 크게 세 가지입니다.

1. `POST /api/v1/telemetry/events` — 이벤트 배치 전송
2. Sentry Flutter SDK 초기화
3. Firebase Crashlytics 초기화

---

## 2. 기기 지문 (Device Fingerprint)

### 2.1 해시 생성 규칙

**⚠️ 원본 기기 ID를 서버로 절대 전송하지 마세요.** 앱 내에서 SHA-256으로 해시 후 전송합니다.

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> buildDeviceHash() async {
  final info = DeviceInfoPlugin();
  String raw;

  if (Platform.isAndroid) {
    final android = await info.androidInfo;
    // androidId + model + version 조합
    raw = '${android.id}:${android.model}:${android.version.release}';
  } else {
    final ios = await info.iosInfo;
    // identifierForVendor + model + version 조합
    final version = ios.systemVersion;   // ← 변수로 분리해서 사용
    raw = '${ios.identifierForVendor}:${ios.model}:$version';
  }

  return sha256.convert(utf8.encode(raw)).toString(); // 64자 hex string
}
```

> **주의**: `android.id` (Android ID)는 공장 초기화 시 변경됩니다. 하드웨어 밴 회피 탐지는 서버 로직으로 보완합니다.

### 2.2 DeviceFingerprintRequest 필드

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `deviceHash` | `String` | ✅ | SHA-256 해시 (64자) |
| `platform` | `String` | ✅ | `"android"` 또는 `"ios"` (소문자) |
| `model` | `String?` | - | 기기 모델명 (예: `"Pixel 8"`, `"iPhone 15"`) |
| `osVersion` | `String?` | - | OS 버전 문자열 (예: `"14"`, `"17.2"`) |
| `appVersion` | `String?` | - | 앱 버전 (예: `"1.2.3"`) |

---

## 3. API 명세

### 3.1 엔드포인트

```
POST /api/v1/telemetry/events
Content-Type: application/json
Authorization: Bearer {token}   ← 선택 (비인증 요청도 허용)
```

> **인증 없이도 전송 가능합니다.** 로그인 상태라면 토큰을 포함하면 `subjectId`가 이벤트에 자동 연결됩니다.  
> 비인증 상태에서는 `subjectId = null`로 저장됩니다.

> **Rate Limit**: IP당 분당 60건

---

### 3.2 Request Body

```json
{
  "deviceFingerprint": {
    "deviceHash": "a3f1d8c2e4b6...",
    "platform": "android",
    "model": "Pixel 8",
    "osVersion": "14",
    "appVersion": "1.2.3"
  },
  "events": [
    {
      "type": "GPS_MOCK_DETECTED",
      "occurredAt": "2026-03-20T10:00:00+09:00",
      "payload": {
        "provider": "mock",
        "accuracy": 0.0
      }
    },
    {
      "type": "APP_FOREGROUND",
      "occurredAt": "2026-03-20T10:00:01+09:00",
      "payload": {
        "appVersion": "1.2.3",
        "locale": "ko-KR"
      }
    }
  ]
}
```

**제약 조건**

| 항목 | 규칙 |
|------|------|
| `events` 최대 개수 | **50개** (초과 시 `400 Bad Request`) |
| `occurredAt` 형식 | ISO 8601 + 타임존 오프셋 필수 (`2026-03-20T10:00:00+09:00`) |
| `type` | 빈 문자열 불가, `@NotBlank` 검증 |
| `deviceHash` | 빈 문자열 불가, `@NotBlank` 검증 |
| `platform` | 빈 문자열 불가, 소문자 권장 |

---

### 3.3 Response — 성공 (HTTP 200)

```json
{
  "success": true,
  "data": {
    "accepted": 2,
    "rejected": 0,
    "deviceBanned": false
  }
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `accepted` | `int` | 저장된 이벤트 수 |
| `rejected` | `int` | 거부된 이벤트 수 |
| `deviceBanned` | `bool` | 200 응답 시 항상 `false` |

---

### 3.4 Response — 기기 차단 (HTTP 403)

```json
{
  "code": "DEVICE_BANNED",
  "message": "This device has been banned from submitting telemetry."
}
```

> **처리 방법**: 앱에서 `deviceBanned` 상태를 로컬에 캐싱하고, 이후 방문 인증 기능을 비활성화합니다.  
> 차단 해제는 Admin 페이지에서만 가능합니다.

---

### 3.5 기타 에러 코드

| HTTP 상태 | 원인 | 앱 대응 |
|-----------|------|---------|
| `400` | 유효성 실패 (빈 `deviceHash`, 50개 초과 등) | 요청 구성 수정 |
| `429` | Rate Limit 초과 | Exponential backoff 후 재시도 |
| `5xx` | 서버 오류 | 로컬 큐 보관 후 재시도 |

---

## 4. 클라이언트 이벤트 타입

### 4.1 보안/어뷰징 관련

서버는 아래 3가지 타입 수신 시 **즉시** Loki 보안 채널에 `SUSPICIOUS_ACTIVITY` 이벤트를 기록합니다.

| 타입 | 발생 시점 | payload 필드 |
|------|---------|-------------|
| `GPS_MOCK_DETECTED` | 모의 위치 앱 감지 | `provider: String`, `accuracy: Double` |
| `TELEPORT_DETECTED` | 비정상적 급격한 위치 이동 | `distanceKm: Double`, `elapsedSec: Int` |
| `RAPID_PLACE_VISIT` | 단시간 다수 장소 방문 시도 | `placeCount: Int`, `windowMinutes: Int` |

추가 탐지 (서버 보안 로그 미트리거, DB 저장만):

| 타입 | 발생 시점 | payload 필드 |
|------|---------|-------------|
| `GPS_ACCURACY_ANOMALY` | 정확도 0.0 또는 음수 | `accuracy: Double`, `latitude: Double`, `longitude: Double` |

### 4.2 앱 라이프사이클

| 타입 | 발생 시점 | payload 필드 |
|------|---------|-------------|
| `APP_FOREGROUND` | 앱 포그라운드 진입 | `appVersion: String`, `locale: String` |
| `APP_BACKGROUND` | 앱 백그라운드 전환 | `sessionDurationSec: Int` |

### 4.3 사용자 행동

| 타입 | 발생 시점 | payload 필드 | 비고 |
|------|---------|-------------|------|
| `SEARCH_QUERY` | 검색어 입력 완료 | `query: String` | 서버에서 금칙어 자동 검사 |
| `REPORT_SUBMITTED` | 콘텐츠 신고 제출 | `targetType: String`, `targetId: String`, `reason: String` | |
| `SCREEN_VIEW` | 화면 진입 | `screenName: String` | |

> **`SEARCH_QUERY` 주의**: 서버가 금칙어 패턴 매칭 후 오염 검색어를 별도 테이블에 저장합니다. `query`는 원문 그대로 전송하세요. 앱에서 필터링하면 안 됩니다.

---

## 5. Flutter 구현 가이드

### 5.1 의존성 추가

```yaml
# pubspec.yaml
dependencies:
  device_info_plus: ^10.x    # 기기 정보 수집
  package_info_plus: ^8.x    # 앱 버전
  crypto: ^3.x               # SHA-256 해시
  sentry_flutter: ^8.x       # Sentry 크래시 리포팅
  firebase_crashlytics: ^4.x # Firebase 크래시 리포팅
  firebase_core: ^3.x
  geolocator: ^11.x          # GPS 탐지
  shared_preferences: ^2.x   # 차단 상태 캐싱
```

### 5.2 main.dart 초기화 순서

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Flutter 에러 → Crashlytics
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 3. Dart 네이티브 에러 → Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 4. Sentry 초기화 후 앱 실행
  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN');
      options.environment =
          const String.fromEnvironment('ENV', defaultValue: 'prod');
      options.tracesSampleRate = 0.2;
      options.sendDefaultPii = false;
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

> `SENTRY_DSN`은 빌드 시 `--dart-define`으로 주입합니다. 소스코드 하드코딩 금지.

### 5.3 TelemetryService 구현 스켈레톤

```dart
// lib/services/telemetry_service.dart

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final _queue = <Map<String, dynamic>>[];
  bool _deviceBanned = false;
  String? _cachedDeviceHash;

  /// 이벤트 큐에 추가
  void enqueue(String type, {Map<String, dynamic>? payload}) {
    if (_deviceBanned) return;
    _queue.add({
      'type': type,
      'occurredAt': DateTime.now().toIso8601String(),
      if (payload != null) 'payload': payload,
    });
  }

  /// 즉시 단건 전송 (보안 이벤트용)
  Future<void> sendImmediately(
    String type, {
    Map<String, dynamic>? payload,
    String? authToken,
  }) async {
    if (_deviceBanned) return;
    await _sendBatch([
      {
        'type': type,
        'occurredAt': DateTime.now().toIso8601String(),
        if (payload != null) 'payload': payload,
      }
    ], authToken);
  }

  /// 큐 일괄 전송 (백그라운드 전환 시 호출)
  Future<void> flush(String? authToken) async {
    if (_deviceBanned || _queue.isEmpty) return;
    final events = List<Map<String, dynamic>>.from(_queue);
    _queue.clear();

    for (var i = 0; i < events.length; i += 50) {
      final chunk = events.sublist(i, (i + 50).clamp(0, events.length));
      await _sendBatch(chunk, authToken);
    }
  }

  Future<void> _sendBatch(
    List<Map<String, dynamic>> events,
    String? authToken,
  ) async {
    try {
      final fp = await _buildFingerprint();
      final body = jsonEncode({'deviceFingerprint': fp, 'events': events});

      final uri = Uri.parse('${Env.baseUrl}/api/v1/telemetry/events');
      final request = await HttpClient().postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      if (authToken != null) {
        request.headers.set('Authorization', 'Bearer $authToken');
      }
      request.write(body);
      final response = await request.close();

      if (response.statusCode == 403) {
        _deviceBanned = true;
        await _persistBannedState();
      }
    } catch (_) {
      // 네트워크 실패 → 큐에 복원
      _queue.insertAll(0, events);
    }
  }

  Future<Map<String, dynamic>> _buildFingerprint() async {
    final hash = await _getDeviceHash();
    final info = DeviceInfoPlugin();
    final pkg = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final d = await info.androidInfo;
      return {
        'deviceHash': hash,
        'platform': 'android',
        'model': d.model,
        'osVersion': d.version.release,
        'appVersion': pkg.version,
      };
    } else {
      final d = await info.iosInfo;
      final ver = d.systemVersion;   // 변수로 분리
      return {
        'deviceHash': hash,
        'platform': 'ios',
        'model': d.utsname.machine,
        'osVersion': ver,
        'appVersion': pkg.version,
      };
    }
  }

  Future<String> _getDeviceHash() async {
    if (_cachedDeviceHash != null) return _cachedDeviceHash!;
    final info = DeviceInfoPlugin();
    String raw;
    if (Platform.isAndroid) {
      final d = await info.androidInfo;
      raw = '${d.id}:${d.model}:${d.version.release}';
    } else {
      final d = await info.iosInfo;
      final ver = d.systemVersion;
      raw = '${d.identifierForVendor}:${d.model}:$ver';
    }
    _cachedDeviceHash = sha256.convert(utf8.encode(raw)).toString();
    return _cachedDeviceHash!;
  }

  Future<void> _persistBannedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('device_banned', true);
  }

  static Future<bool> checkBannedFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('device_banned') ?? false;
  }
}
```

### 5.4 앱 라이프사이클 연결

```dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _telemetry = TelemetryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _telemetry.enqueue('APP_FOREGROUND', payload: {
      'locale': Platform.localeName,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _telemetry.enqueue('APP_BACKGROUND');
      // 백그라운드 전환 시 즉시 플러시
      _telemetry.flush(AuthService.instance.currentToken);
    } else if (state == AppLifecycleState.resumed) {
      _telemetry.enqueue('APP_FOREGROUND');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

### 5.5 GPS 위변조 탐지

```dart
// 장소 방문 인증 직전 호출
Future<Position?> getVerifiedPosition({String? authToken}) async {
  final pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // Mock 위치 탐지
  if (pos.isMocked) {
    await TelemetryService().sendImmediately(
      'GPS_MOCK_DETECTED',
      payload: {'provider': 'mock', 'accuracy': pos.accuracy},
      authToken: authToken,
    );
    return null; // Mock 위치 사용 차단
  }

  // 정확도 이상값
  if (pos.accuracy <= 0) {
    TelemetryService().enqueue('GPS_ACCURACY_ANOMALY', payload: {
      'accuracy': pos.accuracy,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
    });
  }

  return pos;
}

// 텔레포트 탐지 — LocationService 내부에서 이전 위치 비교
void checkTeleport(
  Position prev, DateTime prevTime,
  Position curr, DateTime currTime, {
  String? authToken,
}) {
  final distKm = Geolocator.distanceBetween(
    prev.latitude, prev.longitude,
    curr.latitude, curr.longitude,
  ) / 1000;
  final elapsedSec = currTime.difference(prevTime).inSeconds;

  if (elapsedSec < 300 && distKm > 50) {
    TelemetryService().sendImmediately(
      'TELEPORT_DETECTED',
      payload: {'distanceKm': distKm, 'elapsedSec': elapsedSec},
      authToken: authToken,
    );
  }
}
```

### 5.6 검색 이벤트

```dart
// 검색 화면에서 검색 실행 시
void onSearch(String query) {
  TelemetryService().enqueue('SEARCH_QUERY', payload: {'query': query});
  // ... 검색 API 호출
}
```

---

## 6. 기기 차단 처리 흐름

```
앱 → POST /api/v1/telemetry/events
서버 → HTTP 403 { "code": "DEVICE_BANNED" }

앱:
  1. TelemetryService._deviceBanned = true  → 이후 이벤트 전송 중단
  2. SharedPreferences.set('device_banned', true)  → 앱 재시작 후에도 유지
  3. 방문 인증 기능 비활성화 (별도 UI 처리)
```

> 차단 해제는 Admin 페이지 → 기기 차단 관리 → "해제" 버튼으로만 가능합니다.  
> 앱에서 자동 해제 여부 polling 불필요.

---

## 7. 전송 전략 권장

| 상황 | 권장 전송 방식 |
|------|--------------|
| 보안 이벤트 발생 (`GPS_MOCK_DETECTED` 등) | **즉시 단건 전송** (`sendImmediately`) |
| 앱 백그라운드 전환 | **즉시 flush** |
| 앱 종료 (`AppLifecycleState.detached`) | flush 시도 |
| 일반 라이프사이클 / 행동 이벤트 | 큐 누적 → 백그라운드 전환 시 일괄 전송 |
| 네트워크 실패 | 큐에 복원, 다음 flush 시 재시도 |

---

## 8. Sentry DSN 주입 방법

빌드 시 CI/CD 파이프라인에서 환경변수로 주입합니다.

```bash
# Android
flutter build apk \
  --dart-define=SENTRY_DSN=<DSN_VALUE> \
  --dart-define=ENV=prod

# iOS
flutter build ios \
  --dart-define=SENTRY_DSN=<DSN_VALUE> \
  --dart-define=ENV=prod
```

DSN 값은 백엔드팀에서 Sentry 프로젝트 생성 후 별도 전달 예정입니다.

**서버 Sentry와의 구분**

| 대상 | Sentry 프로젝트 | 수집 내용 |
|------|---------------|---------|
| Flutter 앱 | `girlsbandtabi-flutter` | 크래시, Dart 예외 |
| Spring Boot 서버 | `girlsbandtabi-server` | HTTP 500 에러 자동 캡처 |

두 프로젝트는 별도 DSN이며, 같은 Sentry Organization 하위에서 관리합니다.

---

## 9. 구현 체크리스트

- [ ] `deviceHash` — SHA-256 해시만 전송, 원본 기기 ID 비전송 확인
- [ ] `platform` — 소문자 `"android"` / `"ios"` 전송 확인
- [ ] `occurredAt` — 타임존 오프셋 포함 ISO 8601 형식 확인
- [ ] `events` 배열 — 한 번에 최대 50개 분할 전송 확인
- [ ] `HTTP 403 DEVICE_BANNED` — 이후 전송 중단 + SharedPreferences 캐싱 확인
- [ ] 보안 이벤트 — `sendImmediately` 로 즉시 전송 확인
- [ ] 백그라운드 전환 시 — `flush` 호출 확인
- [ ] Sentry DSN — `--dart-define` 주입, 소스코드 하드코딩 없음 확인
- [ ] Firebase Crashlytics — `Firebase.initializeApp` 선행 초기화 확인
- [ ] 개발 빌드 — `setCrashlyticsCollectionEnabled(false)` 비활성화 확인

---

## 10. 빠른 참조

### API

```
POST /api/v1/telemetry/events
Content-Type: application/json
Authorization: Bearer {token}  (선택)

성공:  HTTP 200 { accepted, rejected, deviceBanned: false }
차단:  HTTP 403 { code: "DEVICE_BANNED" }
초과:  HTTP 400 (events > 50개 또는 유효성 실패)
```

### 서버 환경별 Base URL

| 환경 | URL |
|------|-----|
| 로컬 개발 | `http://localhost:8080` |
| 스테이징 | 별도 전달 |
| 프로덕션 | 별도 전달 |

---

> 문의: 백엔드팀 Slack `#backend-dev` 채널
