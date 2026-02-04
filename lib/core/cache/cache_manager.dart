/// EN: Cache management utilities with TTL and policy handling.
/// KO: TTL 및 정책 처리를 포함한 캐시 관리 유틸리티.
library;

import 'dart:async';

import '../error/failure.dart';
import '../logging/app_logger.dart';
import '../storage/local_storage.dart';

/// EN: Cache policy options for fetch strategies.
/// KO: 데이터 가져오기 전략을 위한 캐시 정책 옵션.
enum CachePolicy {
  networkFirst,
  cacheFirst,
  staleWhileRevalidate,
  networkOnly,
  cacheOnly,
}

/// EN: Cache entry containing data and metadata.
/// KO: 데이터와 메타데이터를 포함한 캐시 엔트리.
class CacheEntry<T> {
  const CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  final T data;
  final DateTime cachedAt;
  final Duration? ttl;

  /// EN: Whether the cache entry has expired.
  /// KO: 캐시 엔트리가 만료되었는지 여부.
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(cachedAt.add(ttl!));
  }
}

/// EN: Result of cache resolution.
/// KO: 캐시 해석 결과.
class CacheResult<T> {
  const CacheResult({
    required this.data,
    required this.isFromCache,
    required this.isStale,
  });

  final T data;
  final bool isFromCache;
  final bool isStale;
}

/// EN: Cache manager backed by LocalStorage.
/// KO: LocalStorage 기반 캐시 매니저.
class CacheManager {
  CacheManager(this._localStorage, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final LocalStorage _localStorage;
  final DateTime Function() _now;

  static const String _namespace = 'gbt_cache';

  /// EN: Resolve data based on cache policy.
  /// KO: 캐시 정책에 따라 데이터를 해석합니다.
  Future<CacheResult<T>> resolve<T>({
    required String key,
    required CachePolicy policy,
    required Future<T> Function() fetcher,
    required Map<String, dynamic> Function(T data) toJson,
    required T Function(Map<String, dynamic> json) fromJson,
    Duration? ttl,
  }) async {
    final cached = getJsonEntry(key, fromJson: fromJson);

    switch (policy) {
      case CachePolicy.cacheOnly:
        final entry = cached;
        if (entry == null) {
          throw const CacheFailure('Cache miss', code: 'cache_miss');
        }
        return CacheResult(
          data: entry.data,
          isFromCache: true,
          isStale: entry.isExpired,
        );
      case CachePolicy.networkOnly:
        final data = await fetcher();
        await setJson(key, toJson(data), ttl: ttl);
        return CacheResult(data: data, isFromCache: false, isStale: false);
      case CachePolicy.cacheFirst:
        if (cached != null && !cached.isExpired) {
          final entry = cached;
          return CacheResult(
            data: entry.data,
            isFromCache: true,
            isStale: false,
          );
        }
        final data = await fetcher();
        await setJson(key, toJson(data), ttl: ttl);
        return CacheResult(data: data, isFromCache: false, isStale: false);
      case CachePolicy.networkFirst:
        try {
          final data = await fetcher();
          await setJson(key, toJson(data), ttl: ttl);
          return CacheResult(data: data, isFromCache: false, isStale: false);
        } catch (e, stackTrace) {
          if (cached != null) {
            final entry = cached;
            AppLogger.warning(
              'Network fetch failed, using cache',
              data: e,
              tag: 'CacheManager',
            );
            return CacheResult(
              data: entry.data,
              isFromCache: true,
              isStale: entry.isExpired,
            );
          }
          AppLogger.error(
            'Network fetch failed with no cache',
            error: e,
            stackTrace: stackTrace,
            tag: 'CacheManager',
          );
          rethrow;
        }
      case CachePolicy.staleWhileRevalidate:
        final entry = cached;
        if (entry != null) {
          unawaited(_refresh(key, fetcher, toJson, ttl));
          return CacheResult(
            data: entry.data,
            isFromCache: true,
            isStale: entry.isExpired,
          );
        }
        final data = await fetcher();
        await setJson(key, toJson(data), ttl: ttl);
        return CacheResult(data: data, isFromCache: false, isStale: false);
    }
  }

  /// EN: Save JSON object to cache.
  /// KO: JSON 객체를 캐시에 저장합니다.
  Future<void> setJson(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
  }) async {
    final payload = <String, dynamic>{
      'cachedAt': _now().toIso8601String(),
      if (ttl != null) 'ttlSeconds': ttl.inSeconds,
      'data': value,
    };

    await _localStorage.setJson(_wrapKey(key), payload);
  }

  /// EN: Get cached JSON entry (with metadata).
  /// KO: 캐시된 JSON 엔트리를 가져옵니다 (메타데이터 포함).
  CacheEntry<T>? getJsonEntry<T>(
    String key, {
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    final payload = _localStorage.getJson(_wrapKey(key));
    if (payload == null) return null;

    final cachedAtRaw = payload['cachedAt'];
    final cachedAt = cachedAtRaw is String
        ? DateTime.tryParse(cachedAtRaw)
        : null;
    final ttlSeconds = payload['ttlSeconds'];
    final dataRaw = payload['data'];

    if (cachedAt == null || dataRaw is! Map<String, dynamic>) {
      AppLogger.warning(
        'Invalid cache payload, removing entry',
        tag: 'CacheManager',
      );
      _localStorage.remove(_wrapKey(key));
      return null;
    }

    final ttl = ttlSeconds is int ? Duration(seconds: ttlSeconds) : null;

    return CacheEntry<T>(data: fromJson(dataRaw), cachedAt: cachedAt, ttl: ttl);
  }

  /// EN: Remove cached entry.
  /// KO: 캐시 엔트리를 삭제합니다.
  Future<void> remove(String key) async {
    await _localStorage.remove(_wrapKey(key));
  }

  /// EN: Clear all cache entries using the cache namespace.
  /// KO: 캐시 네임스페이스의 모든 엔트리를 삭제합니다.
  Future<void> clearAll() async {
    // EN: LocalStorage has no namespace clear, so this is a no-op by default.
    // KO: LocalStorage는 네임스페이스 삭제를 지원하지 않아 기본적으로 no-op입니다.
    AppLogger.warning('Clear-all cache requested but not supported');
  }

  Future<void> _refresh<T>(
    String key,
    Future<T> Function() fetcher,
    Map<String, dynamic> Function(T data) toJson,
    Duration? ttl,
  ) async {
    try {
      final data = await fetcher();
      await setJson(key, toJson(data), ttl: ttl);
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Background cache refresh failed',
        data: e,
        tag: 'CacheManager',
      );
      AppLogger.error(
        'Background cache refresh error',
        error: e,
        stackTrace: stackTrace,
        tag: 'CacheManager',
      );
    }
  }

  String _wrapKey(String key) => '$_namespace:$key';
}
