# 🚀 Girls Band Tabi - Build & Deployment Guide

## 📍 Configuration Location / 설정 위치

**모든 환경 설정은 여기에서 관리됩니다:**
```
📁 lib/core/config/app_config.dart
```

## 🌿 Git Branch Strategy / Git 브랜치 전략

### 1. Development (개발환경)
- **Branch**: `feature/*`, `develop`, 기타 개발 브랜치
- **API URL**: `http://10.0.2.2:8080` (Android Emulator)
- **Target**: 로컬 개발 및 테스트

### 2. Staging (스테이징환경)  
- **Branch**: `staging`
- **API URL**: 스테이징 서버 URL (staging 브랜치에서 설정)
- **Target**: QA 테스트 및 사전 배포 검증

### 3. Production (프로덕션환경)
- **Branch**: `main` 또는 `master`  
- **API URL**: 실제 서비스 서버 URL (main 브랜치에서 설정)
- **Target**: Google Play Store 배포

## 🛠️ Environment Configuration / 환경 설정

### 현재 환경 변경
`lib/core/config/app_config.dart` 파일에서:

```dart
// 개발환경
static const Environment currentEnvironment = Environment.development;

// 스테이징환경  
static const Environment currentEnvironment = Environment.staging;

// 프로덕션환경
static const Environment currentEnvironment = Environment.production;
```

### API URL 변경
같은 파일의 `baseUrl` getter에서:

```dart
case Environment.production:
  return 'https://your-actual-production-url.com';  // ← 여기를 수정

case Environment.staging:
  return 'https://your-staging-url.com';  // ← 여기를 수정
```

## 📱 Build Commands / 빌드 명령어

### Development Build (개발용)
```bash
# Debug APK
flutter build apk --debug

# Release APK (테스트용)
flutter build apk --release
```

### Staging Build (스테이징용)
```bash
# 1. staging 브랜치로 체크아웃
git checkout staging

# 2. app_config.dart에서 Environment.staging으로 설정

# 3. 스테이징 URL 설정 후 빌드
flutter build apk --release --flavor staging
```

### Production Build (배포용)
```bash
# 1. main 브랜치로 체크아웃
git checkout main

# 2. app_config.dart에서 Environment.production으로 설정

# 3. 프로덕션 URL 설정 후 빌드
flutter build appbundle --release

# 또는 APK
flutter build apk --release
```

## 📋 Pre-Deployment Checklist / 배포 전 체크리스트

### 🔍 Before Staging Deployment
- [ ] `currentEnvironment = Environment.staging`
- [ ] Staging API URL이 올바르게 설정됨
- [ ] 스테이징 서버가 실행 중
- [ ] 테스트 데이터 확인

### 🔍 Before Production Deployment  
- [ ] `currentEnvironment = Environment.production`
- [ ] Production API URL이 올바르게 설정됨
- [ ] 프로덕션 서버가 실행 중
- [ ] 앱 버전 번호 업데이트 (`pubspec.yaml`)
- [ ] 앱 서명 키 확인
- [ ] Google Play Console 준비
- [ ] 모든 테스트 통과
- [ ] 성능 및 메모리 최적화 확인

## 🔧 Quick Configuration / 빠른 설정

### 로컬 개발용
```bash
# 아무것도 변경하지 않음 (기본값이 development)
flutter run
```

### 스테이징 배포용
1. `lib/core/config/app_config.dart` 열기
2. `currentEnvironment = Environment.staging` 설정
3. `case Environment.staging:` 섹션에서 스테이징 URL 설정
4. 빌드: `flutter build appbundle --release`

### 프로덕션 배포용
1. `lib/core/config/app_config.dart` 열기  
2. `currentEnvironment = Environment.production` 설정
3. `case Environment.production:` 섹션에서 프로덕션 URL 설정
4. 빌드: `flutter build appbundle --release`

## 🌍 URL Examples / URL 예시

```dart
// Development (로컬)
case Environment.development:
  return 'http://10.0.2.2:8080';

// Staging (테스트 서버)
case Environment.staging:
  return 'https://staging-api.girls-band-tabi.com';
  
// Production (실제 서비스)
case Environment.production:
  return 'https://api.girls-band-tabi.com';
```

## ⚠️ Important Notes / 중요 사항

1. **Git 브랜치별 관리**: 각 브랜치에서 해당 환경의 URL을 설정
2. **커밋 전 확인**: URL 변경사항을 커밋하기 전에 반드시 확인
3. **보안**: 프로덕션 URL을 public 레포지토리에 노출하지 않도록 주의
4. **테스트**: 배포 전 반드시 해당 환경에서 API 연결 테스트

## 🔍 Troubleshooting / 문제 해결

### API 연결 실패시
1. `app_config.dart`에서 현재 환경 확인
2. 해당 환경의 API URL이 올바른지 확인  
3. 서버가 실행 중인지 확인
4. 네트워크 연결 상태 확인

### 빌드 실패시
1. `flutter clean` 실행
2. `flutter pub get` 실행
3. 환경 설정이 올바른지 확인
4. 다시 빌드 시도