import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/upload_model.dart';
import '../services/upload_service.dart';

const _defaultPageSize = 20;

final uploadServiceProvider = Provider<UploadService>((ref) => UploadService());

class UploadsState {
  const UploadsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.total = 0,
    this.error,
  });

  final List<UploadItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final int total;
  final String? error;

  UploadsState copyWith({
    List<UploadItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    int? total,
    Object? error = _sentinel,
  }) {
    return UploadsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

class UploadsNotifier extends StateNotifier<UploadsState> {
  UploadsNotifier(this._service) : super(const UploadsState());

  final UploadService _service;

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      error: null,
      hasMore: true,
      page: 0,
      total: 0,
    );
    try {
      final page = await _service.getMyUploads(page: 0, size: _defaultPageSize);
      final hasMore = (page.page + 1) * page.size < page.total;
      state = state.copyWith(
        items: page.items,
        page: page.page,
        total: page.total,
        hasMore: hasMore,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await _service.getMyUploads(
        page: nextPage,
        size: _defaultPageSize,
      );
      final hasMore = (page.page + 1) * page.size < page.total;
      final existing = state.items.map((e) => e.uploadId).toSet();
      final additional = <UploadItem>[];
      for (final item in page.items) {
        if (existing.add(item.uploadId)) {
          additional.add(item);
        }
      }
      state = state.copyWith(
        items: [...state.items, ...additional],
        page: page.page,
        total: page.total,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void removeById(String uploadId) {
    state = state.copyWith(
      items: state.items.where((item) => item.uploadId != uploadId).toList(),
    );
  }

  void upsert(UploadItem item) {
    final items = [...state.items];
    final index = items.indexWhere((e) => e.uploadId == item.uploadId);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    state = state.copyWith(items: items);
  }
}

final uploadsProvider =
    StateNotifierProvider.autoDispose<UploadsNotifier, UploadsState>((ref) {
      final notifier = UploadsNotifier(ref.read(uploadServiceProvider));
      Future.microtask(() => notifier.loadInitial());
      return notifier;
    });

const Object _sentinel = Object();
