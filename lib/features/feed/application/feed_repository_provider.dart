/// EN: Feed repository provider and data-source wiring.
/// KO: 피드 리포지토리 프로바이더 및 데이터소스 구성.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/datasources/feed_remote_data_source.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../domain/repositories/feed_repository.dart';

/// EN: Feed repository provider.
/// KO: 피드 리포지토리 프로바이더.
final feedRepositoryProvider = FutureProvider<FeedRepository>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = await ref.read(cacheManagerProvider.future);
  return FeedRepositoryImpl(
    remoteDataSource: FeedRemoteDataSource(apiClient),
    cacheManager: cacheManager,
  );
});
