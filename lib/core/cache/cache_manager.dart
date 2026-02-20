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
  bool get isExpired => isExpiredAt(DateTime.now());

  /// EN: Whether the cache entry has expired at a given time.
  /// KO: 주어진 시점을 기준으로 캐시 엔트리가 만료되었는지 여부.
  bool isExpiredAt(DateTime now) {
    if (ttl == null) return false;
    return now.isAfter(cachedAt.add(ttl!));
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
  CacheManager(
    this._localStorage, {
    DateTime Function()? now,
    Duration cacheFirstRevalidateInterval = const Duration(minutes: 10),
  }) : _now = now ?? DateTime.now,
       _cacheFirstRevalidateInterval = cacheFirstRevalidateInterval;

  final LocalStorage _localStorage;
  final DateTime Function() _now;
  // EN: Default interval to probe server changes for cacheFirst hits.
  // KO: cacheFirst 적중 시 서버 변경사항을 확인하는 기본 주기.
  final Duration _cacheFirstRevalidateInterval;
  final Map<String, Future<void>> _refreshTasks = {};

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
    // EN: Optional background revalidation interval for cacheFirst hits.
    // KO: cacheFirst 캐시 적중 시 백그라운드 재검증 주기(선택).
    Duration? revalidateAfter,
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
          isStale: _isExpired(entry),
        );
      case CachePolicy.networkOnly:
        final data = await fetcher();
        await setJson(key, toJson(data), ttl: ttl);
        return CacheResult(data: data, isFromCache: false, isStale: false);
      case CachePolicy.cacheFirst:
        if (cached != null && !_isExpired(cached)) {
          if (_shouldRevalidate(cached, revalidateAfter)) {
            _scheduleRefresh(key, fetcher, toJson, ttl);
          }
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
              isStale: _isExpired(entry),
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
          _scheduleRefresh(key, fetcher, toJson, ttl);
          return CacheResult(
            data: entry.data,
            isFromCache: true,
            isStale: _isExpired(entry),
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
    final prefix = '$_namespace:';
    final keys = _localStorage
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList(growable: false);
    for (final key in keys) {
      await _localStorage.remove(key);
    }
    AppLogger.info(
      'Cache namespace cleared',
      data: {'removed': keys.length},
      tag: 'CacheManager',
    );
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

  bool _shouldRevalidate(CacheEntry<dynamic> entry, Duration? revalidateAfter) {
    final interval = revalidateAfter ?? _cacheFirstRevalidateInterval;
    if (interval <= Duration.zero) {
      return true;
    }
    return _now().difference(entry.cachedAt) >= interval;
  }

  bool _isExpired(CacheEntry<dynamic> entry) {
    return entry.isExpiredAt(_now());
  }

  void _scheduleRefresh<T>(
    String key,
    Future<T> Function() fetcher,
    Map<String, dynamic> Function(T data) toJson,
    Duration? ttl,
  ) {
    final wrappedKey = _wrapKey(key);
    if (_refreshTasks.containsKey(wrappedKey)) {
      return;
    }

    final task = _refresh(key, fetcher, toJson, ttl).whenComplete(() {
      _refreshTasks.remove(wrappedKey);
    });
    _refreshTasks[wrappedKey] = task;
    unawaited(task);
  }

  String _wrapKey(String key) => '$_namespace:$key';
}
