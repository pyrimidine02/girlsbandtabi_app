import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../network/api_client.dart';
import '../network/network_client.dart';
import '../persistence/selection_persistence.dart';

/// EN: Provider for secure storage instance
/// KO: 보안 저장소 인스턴스를 위한 프로바이더
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
});

/// EN: Provider for shared preferences instance - must be overridden with actual instance
/// KO: 공유 환경설정 인스턴스 프로바이더 - 실제 인스턴스로 재정의되어야 함
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences provider must be overridden in main.dart with actual instance',
  );
});

/// EN: Provider for Dio HTTP client instance
/// KO: Dio HTTP 클라이언트 인스턴스 프로바이더
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // EN: Add interceptors for authentication and logging
  // KO: 인증 및 로깅을 위한 인터셉터 추가
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // EN: Add auth token to requests (except auth endpoints)
        // KO: 요청에 인증 토큰 추가 (인증 엔드포인트 제외)
        final secureStorage = ref.read(secureStorageProvider);
        final isAuthEndpoint = options.path.contains('/auth/') ||
            options.extra['skipAuth'] == true;

        if (!isAuthEndpoint) {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // EN: Handle token refresh on 401 errors
        // KO: 401 오류 시 토큰 갱신 처리
        if (error.response?.statusCode == 401) {
          // EN: Token refresh logic would go here
          // KO: 토큰 갱신 로직이 여기에 들어갑니다
          // For now, just pass the error through
          handler.next(error);
        } else {
          handler.next(error);
        }
      },
    ),
  );

  // EN: Add logging interceptor in debug mode
  // KO: 디버그 모드에서 로깅 인터셉터 추가
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      logPrint: (object) {
        // EN: Custom log print for better debugging
        // KO: 더 나은 디버깅을 위한 커스텀 로그 출력
        print('[DIO] $object');
      },
    ),
  );

  return dio;
});

/// EN: Provider for network client implementation
/// KO: 네트워크 클라이언트 구현 프로바이더
final networkClientProvider = Provider<NetworkClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioNetworkClient(
    dio: dio,
    defaultDecoder: (data) {
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is List) {
        return {'data': data};
      }
      return {'value': data};
    },
  );
});

/// EN: Provider for API client instance
/// KO: API 클라이언트 인스턴스 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});

/// EN: Provider for selection persistence manager
/// KO: 선택 지속성 관리자 프로바이더
final selectionPersistenceProvider = Provider<SelectionPersistence>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SelectionPersistence(preferences: prefs, ref: ref);
});

/// EN: Provider that initializes selection persistence and watches for changes
/// KO: 선택 지속성을 초기화하고 변경 사항을 감시하는 프로바이더
final selectionPersistenceManagerProvider = FutureProvider<void>((ref) async {
  final persistence = ref.watch(selectionPersistenceProvider);
  await persistence.initialize();
});
