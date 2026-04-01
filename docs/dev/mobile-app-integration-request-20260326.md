# 모바일 앱 연동 요청서 — 푸시 알림 고도화 & 기기 지문 연동

> 작성일: 2026-03-26
> 대상: Flutter 앱팀
> 관련 백엔드 배포 버전: V157 ~ V160 (migration 기준)
> 우선순위: **필수** / **권장** / **선택** 세 단계로 구분

---

## 개요

백엔드에 아래 두 가지 기능이 배포되었습니다.

1. **기기 지문-유저 연동 (Device Fingerprint Linking)** — 기기 하드웨어 해시를 서버에 전달해 어떤 기기에서 어떤 유저가 로그인했는지 추적 가능하게 합니다. 어뷰저 밴/추적에 활용됩니다.
2. **푸시 알림 고도화** — 알림 오픈 추적, 조용한 시간(Quiet Hours) 정확성, Quiet Hours 적용을 위한 타임존 정보 전달이 포함됩니다.

모바일 쪽에서 반영해야 할 API 변경사항을 아래에 상세히 기술합니다.

---

## 1. [필수] 기기 등록 API에 `deviceHash` 추가

### 배경

서버가 `device_fingerprint_user_links` 테이블을 통해 특정 하드웨어 기기 ↔ 유저 계정 간 연결 이력을 관리합니다. 이 연결 정보는 관리자 밴 처리 시 같은 기기를 사용한 계정을 일괄 조회하는 데 사용됩니다. 앱이 `deviceHash`를 보내지 않으면 이 연결 레코드가 생성되지 않습니다.

### 변경된 엔드포인트

```
POST /api/v1/notifications/devices
```

### 기존 요청 Body

```json
{
  "platform": "IOS",
  "provider": "APNS",
  "deviceId": "ios-<UUID>",
  "pushToken": "<APNs 토큰>",
  "appVersion": "1.2.3",
  "locale": "ko-KR",
  "timezone": "Asia/Seoul"
}
```

### 변경 후 요청 Body

```json
{
  "platform": "IOS",
  "provider": "APNS",
  "deviceId": "ios-<UUID>",
  "pushToken": "<APNs 토큰>",
  "appVersion": "1.2.3",
  "locale": "ko-KR",
  "timezone": "Asia/Seoul",
  "deviceHash": "<hardware-derived SHA-256 hex string>"
}
```

### `deviceHash` 생성 방법

`deviceHash`는 **기기 고유 하드웨어 식별자**를 SHA-256으로 해시한 **소문자 16진수 문자열 (64자)**입니다.

| 플랫폼 | 사용 가능한 식별자 | 참고 |
|--------|------------------|------|
| **iOS** | `identifierForVendor` (UIDevice) | 앱 재설치 시 변경될 수 있음. 가능하면 Keychain에 저장해 영속 유지 |
| **Android** | `ANDROID_ID` (Settings.Secure) | 기기 초기화 시 변경됨 |
| **공통 권장** | 위 값을 직접 전송하지 말고, `SHA-256(rawId + "gbt-salt-v1")` 형태로 해시 후 전송 |

**Flutter 구현 예시:**

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

String computeDeviceHash(String rawDeviceId) {
  final input = '$rawDeviceId:gbt-salt-v1';
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString(); // 소문자 16진수 64자
}
```

> **주의사항:**
> - 최대 64자 제한 — SHA-256 hex(64자) 그대로 사용하면 딱 맞습니다.
> - `null` 전송 허용 (optional) — 해시를 수집할 수 없는 환경에서는 필드 자체를 생략하거나 `null`로 보내도 서버가 정상 처리합니다.
> - 앱 업데이트 없이 기존 유저의 연결 레코드 소급 생성은 불가합니다. 다음 번 디바이스 등록(앱 재설치, 토큰 갱신) 시 자동으로 생성됩니다.

---

## 2. [필수] 알림 오픈 이벤트 전송

### 배경

사용자가 푸시 알림을 탭해서 앱을 열 때 서버에 오픈 이벤트를 전송해야 합니다. 이 데이터로 알림별 오픈율(CTR) 측정이 가능해집니다. 중복 호출은 서버에서 자동으로 무시(idempotent)합니다.

### 신규 엔드포인트

```
POST /api/v1/notifications/{notificationId}/open
Authorization: Bearer <access_token>
```

### 쿼리 파라미터 (선택)

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `deviceId` | `string` | 어떤 기기에서 열었는지 식별 (분석용). 필수 아님. |

### 요청 Body

없음 (Body 불필요)

### 응답 예시

```json
{
  "success": true,
  "data": {
    "recorded": true
  }
}
```

### 호출 시점

**Flutter FCM/APNs 핸들러에서 알림 탭 이벤트 수신 시** 호출합니다.

```dart
// firebase_messaging 기준 예시
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  final notificationId = message.data['notificationId'];
  if (notificationId != null) {
    await apiClient.post(
      '/api/v1/notifications/$notificationId/open',
      queryParameters: {'deviceId': localDeviceId},
    );
  }
});

// 앱 종료 상태에서 탭으로 시작된 경우
final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
  final notificationId = initialMessage.data['notificationId'];
  if (notificationId != null) {
    await apiClient.post('/api/v1/notifications/$notificationId/open');
  }
}
```

> **주의사항:**
> - `notificationId`는 서버가 푸시 payload 내에 포함해 전송하는 UUID입니다. 기존 payload의 `notificationId` 필드를 그대로 사용하면 됩니다.
> - 인증 토큰 만료 등으로 실패해도 UX에 영향 없으므로 실패를 조용히 처리(fire-and-forget)하면 됩니다.
> - 이미 기록된 `(notificationId, userId)` 쌍은 서버가 중복 insert를 건너뛰므로 앱에서 중복 방지 로직 불필요합니다.

---

## 3. [권장] 타임존 정보 전달 (Quiet Hours 정확도)

### 배경

서버는 **Quiet Hours(조용한 시간)** 기능을 통해 기기 현지 시간 기준 22:00 ~ 08:00 사이에 발송 예정인 푸시를 다음날 08:00으로 자동 지연합니다. 이 기능이 정확하게 동작하려면 앱이 기기 등록 시 **IANA 타임존 문자열**을 보내야 합니다.

### 이미 있는 필드 (기존 `POST /api/v1/notifications/devices`)

```json
{
  "timezone": "Asia/Seoul"
}
```

### 올바른 타임존 형식

IANA Time Zone Database 이름을 사용합니다.

| 예시 | 설명 |
|------|------|
| `Asia/Seoul` | 한국 표준시 (KST, UTC+9) |
| `America/New_York` | 미국 동부 |
| `Europe/London` | 영국 |
| `Asia/Tokyo` | 일본 |

**Flutter 구현 예시:**

```dart
// timezone 패키지 사용 (pub.dev: timezone ^0.9.x)
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final String localTimezone = await FlutterTimezone.getLocalTimezone();
// 예: "Asia/Seoul"
```

> **주의사항:**
> - `timezone` 미전송 시 서버는 Quiet Hours를 적용하지 않고 즉시 발송합니다 (안전한 fallback).
> - UTC±HH:MM 형식(`+09:00` 등)이 아닌 **IANA 이름** 형식으로 보내야 합니다.
> - 사용자가 타임존을 변경할 수 있으므로 앱 시작 시마다 디바이스 등록/갱신 호출 시 최신값을 보내는 것을 권장합니다.

---

## 4. [선택] `locale` 필드 갱신

기존에도 있던 필드입니다. 현재 서버에서는 조용한 시간 계산에 `timezone`을 사용하며 `locale`은 분석/미래 확장용입니다. 이미 전송 중이라면 변경 없음.

---

## API 변경 요약표

| 항목 | 엔드포인트 | 변경 유형 | 우선순위 |
|------|-----------|----------|---------|
| `deviceHash` 필드 추가 | `POST /api/v1/notifications/devices` | 기존 Body에 옵셔널 필드 추가 | **필수** |
| 알림 오픈 이벤트 전송 | `POST /api/v1/notifications/{id}/open` | **신규 엔드포인트** | **필수** |
| `timezone` 정확한 전달 | `POST /api/v1/notifications/devices` | 기존 필드 입력 품질 개선 | **권장** |

---

## 하위 호환성 확인

모든 신규 필드는 **optional**이며 기존 요청 포맷도 그대로 동작합니다. 앱 업데이트 없이 구버전이 요청을 보내도 서버는 정상 처리합니다.

| 시나리오 | 서버 동작 |
|---------|---------|
| `deviceHash` 없이 기기 등록 | 지문 연결 레코드 미생성, 나머지 정상 동작 |
| `/open` 미호출 | 오픈 이벤트 미기록, 알림 수신/표시 정상 동작 |
| `timezone` 미전송 | Quiet Hours 미적용, 즉시 발송 |

---

## 문의

백엔드 담당자에게 Slack DM 또는 이 문서의 Github 이슈로 문의 주세요.
