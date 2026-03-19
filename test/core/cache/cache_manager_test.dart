import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:girlsbandtabi_app/core/cache/cache_manager.dart';
import 'package:girlsbandtabi_app/core/error/failure.dart';
import 'package:girlsbandtabi_app/core/storage/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('cacheFirst returns cached data without calling fetcher', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    final manager = CacheManager(storage);

    var fetchCount = 0;

    await manager.setJson('home_summary', {
      'title': 'cached',
    }, ttl: const Duration(minutes: 10));

    final result = await manager.resolve<Map<String, dynamic>>(
      key: 'home_summary',
      policy: CachePolicy.cacheFirst,
      fetcher: () async {
        fetchCount += 1;
        return {'title': 'network'};
      },
      toJson: (data) => data,
      fromJson: (json) => json,
      ttl: const Duration(minutes: 10),
    );

    expect(fetchCount, 0);
    expect(result.isFromCache, true);
    expect(result.data['title'], 'cached');
  });

  test('networkFirst falls back to cache on fetch failure', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    final manager = CacheManager(storage);

    await manager.setJson('places', {
      'count': 3,
    }, ttl: const Duration(minutes: 10));

    final result = await manager.resolve<Map<String, dynamic>>(
      key: 'places',
      policy: CachePolicy.networkFirst,
      fetcher: () async {
        throw Exception('network down');
      },
      toJson: (data) => data,
      fromJson: (json) => json,
      ttl: const Duration(minutes: 10),
    );

    expect(result.isFromCache, true);
    expect(result.data['count'], 3);
  });

  test('cacheOnly throws CacheFailure on miss', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    final manager = CacheManager(storage);

    await expectLater(
      manager.resolve<Map<String, dynamic>>(
        key: 'missing',
        policy: CachePolicy.cacheOnly,
        fetcher: () async => {'x': 1},
        toJson: (data) => data,
        fromJson: (json) => json,
      ),
      throwsA(isA<CacheFailure>()),
    );
  });

  test('removeByPrefix removes matching cache entries only', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    final manager = CacheManager(storage);

    await manager.setJson('post_list:bang-dream:p0:s20', {'items': []});
    await manager.setJson('post_list:bang-dream:p1:s20', {'items': []});
    await manager.setJson('post_list:girls-band-cry:p0:s20', {'items': []});

    final removed = await manager.removeByPrefix('post_list:bang-dream:');

    expect(removed, 2);
    expect(
      manager.getJsonEntry<Map<String, dynamic>>(
        'post_list:bang-dream:p0:s20',
        fromJson: (json) => json,
      ),
      isNull,
    );
    expect(
      manager.getJsonEntry<Map<String, dynamic>>(
        'post_list:girls-band-cry:p0:s20',
        fromJson: (json) => json,
      ),
      isNotNull,
    );
  });

  test(
    'cacheFirst triggers background revalidation when entry is old',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      var now = DateTime(2026, 2, 12, 9, 0, 0);
      final manager = CacheManager(storage, now: () => now);

      await manager.setJson('home_summary', {
        'title': 'cached',
      }, ttl: const Duration(hours: 1));

      now = now.add(const Duration(minutes: 11));
      var fetchCount = 0;
      final result = await manager.resolve<Map<String, dynamic>>(
        key: 'home_summary',
        policy: CachePolicy.cacheFirst,
        revalidateAfter: const Duration(minutes: 10),
        fetcher: () async {
          fetchCount += 1;
          return {'title': 'network'};
        },
        toJson: (data) => data,
        fromJson: (json) => json,
        ttl: const Duration(hours: 1),
      );

      expect(result.isFromCache, true);
      expect(result.data['title'], 'cached');

      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(fetchCount, 1);
      final updated = manager.getJsonEntry<Map<String, dynamic>>(
        'home_summary',
        fromJson: (json) => json,
      );
      expect(updated?.data['title'], 'network');
    },
  );

  test('cacheFirst background revalidation is de-duplicated per key', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    var now = DateTime(2026, 2, 12, 9, 0, 0);
    final manager = CacheManager(storage, now: () => now);

    await manager.setJson('places', {
      'count': 1,
    }, ttl: const Duration(hours: 1));

    now = now.add(const Duration(minutes: 11));
    var fetchCount = 0;

    Future<Map<String, dynamic>> fetcher() async {
      fetchCount += 1;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return {'count': 2};
    }

    await Future.wait([
      manager.resolve<Map<String, dynamic>>(
        key: 'places',
        policy: CachePolicy.cacheFirst,
        revalidateAfter: const Duration(minutes: 10),
        fetcher: fetcher,
        toJson: (data) => data,
        fromJson: (json) => json,
        ttl: const Duration(hours: 1),
      ),
      manager.resolve<Map<String, dynamic>>(
        key: 'places',
        policy: CachePolicy.cacheFirst,
        revalidateAfter: const Duration(minutes: 10),
        fetcher: fetcher,
        toJson: (data) => data,
        fromJson: (json) => json,
        ttl: const Duration(hours: 1),
      ),
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(fetchCount, 1);
  });

  test(
    'offline mode forces cache fallback and skips fetch for cacheFirst',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final manager = CacheManager(storage, isOnline: () async => false);

      await manager.setJson('offline_home', {
        'title': 'cached_offline',
      }, ttl: const Duration(minutes: 10));

      var fetchCount = 0;
      final result = await manager.resolve<Map<String, dynamic>>(
        key: 'offline_home',
        policy: CachePolicy.cacheFirst,
        fetcher: () async {
          fetchCount += 1;
          return {'title': 'network'};
        },
        toJson: (data) => data,
        fromJson: (json) => json,
        ttl: const Duration(minutes: 10),
        revalidateAfter: const Duration(minutes: 1),
      );

      expect(fetchCount, 0);
      expect(result.isFromCache, true);
      expect(result.data['title'], 'cached_offline');
    },
  );

  test(
    'offline mode returns offline_cache_miss when no cache exists',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final manager = CacheManager(storage, isOnline: () async => false);

      await expectLater(
        manager.resolve<Map<String, dynamic>>(
          key: 'offline_missing',
          policy: CachePolicy.networkFirst,
          fetcher: () async => {'x': 1},
          toJson: (data) => data,
          fromJson: (json) => json,
        ),
        throwsA(
          isA<CacheFailure>().having(
            (failure) => failure.code,
            'code',
            'offline_cache_miss',
          ),
        ),
      );
    },
  );
}
