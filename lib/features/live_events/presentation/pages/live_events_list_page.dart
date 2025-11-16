import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/kt_colors.dart';
import '../../../../widgets/flow_components.dart';
import '../../application/providers/live_events_providers.dart';
import '../../domain/entities/live_event.dart';
import '../widgets/live_event_card.dart';

/// EN: Live events list page showing all live events
/// KO: 모든 라이브 이벤트를 보여주는 라이브 이벤트 목록 페이지
class LiveEventsListPage extends ConsumerStatefulWidget {
  const LiveEventsListPage({super.key});

  @override
  ConsumerState<LiveEventsListPage> createState() => _LiveEventsListPageState();
}

class _LiveEventsListPageState extends ConsumerState<LiveEventsListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // EN: Load live events when page initializes
    // KO: 페이지 초기화 시 라이브 이벤트 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveEventsControllerProvider.notifier).loadLiveEvents();
    });

    // EN: Set up scroll listener for pagination
    // KO: 페이지네이션을 위한 스크롤 리스너 설정
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      // EN: Load more when user scrolls to 90% of the list
      // KO: 사용자가 목록의 90%까지 스크롤하면 더 로드
      final controller = ref.read(liveEventsControllerProvider.notifier);
      if (controller.hasMore && !controller.isLoading) {
        controller.loadMoreLiveEvents();
      }
    }
  }

  void _onSearch(String query) {
    final controller = ref.read(liveEventsControllerProvider.notifier);
    controller.searchLiveEvents(query: query);
  }

  void _onRefresh() {
    final controller = ref.read(liveEventsControllerProvider.notifier);
    controller.refresh();
  }

  void _onFilterByStatus(LiveEventStatus? status) {
    final controller = ref.read(liveEventsControllerProvider.notifier);
    controller.filterByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveEventsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('라이브 이벤트'),
        backgroundColor: KTColors.accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // EN: Search bar
          // KO: 검색 바
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '이벤트 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: _onSearch,
            ),
          ),

          // EN: Filter chips
          // KO: 필터 칩들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: false,
                  onSelected: (_) => _onFilterByStatus(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('예정'),
                  selected: false,
                  onSelected: (_) => _onFilterByStatus(LiveEventStatus.scheduled),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('진행 중'),
                  selected: false,
                  onSelected: (_) => _onFilterByStatus(LiveEventStatus.live),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('완료'),
                  selected: false,
                  onSelected: (_) => _onFilterByStatus(LiveEventStatus.completed),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // EN: Events list
          // KO: 이벤트 목록
          Expanded(
            child: state.when(
              initial: () => const Center(
                child: Text('라이브 이벤트를 불러오세요'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              success: (events, hasMore, currentPage) {
                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '등록된 이벤트가 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _onRefresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= events.length) {
                        // EN: Loading indicator for pagination
                        // KO: 페이지네이션용 로딩 인디케이터
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LiveEventCard(
                          event: event,
                          onTap: () {
                            // EN: Navigate to event detail
                            // KO: 이벤트 상세로 이동
                            // Navigator.pushNamed(context, '/live/${event.id}');
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              error: (failure) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      failure.message ?? '오류가 발생했습니다',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
