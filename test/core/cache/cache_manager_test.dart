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
}
