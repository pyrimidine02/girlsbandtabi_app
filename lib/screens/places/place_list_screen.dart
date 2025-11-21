import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_spacing.dart';
import '../../models/favorite_model.dart';
import '../../models/place_model.dart' as model;
import '../../providers/content_filter_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/places_api_provider.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

/// EN: Main places list screen with search, filters, and grid/list view.
/// KO: 검색, 필터, 그리드/리스트 뷰를 포함한 메인 장소 목록 화면.
class PlaceListScreen extends ConsumerStatefulWidget {
  const PlaceListScreen({super.key});

  @override
  ConsumerState<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends ConsumerState<PlaceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;
  String? _selectedRegion;

  // EN: Map regions to standardized prefecture names
  // KO: 지역을 표준화된 현 이름으로 매핑
  String _normalizePrefectureName(String regionName) {
    final name = regionName.toLowerCase();
    
    // Tokyo
    if (name.contains('tokyo') || name.contains('도쿄') || name.contains('東京')) {
      return '도쿄도';
    }
    // Kanagawa
    if (name.contains('kanagawa') || name.contains('가나가와') || name.contains('神奈川')) {
      return '가나가와현';
    }
    // Saitama
    if (name.contains('saitama') || name.contains('사이타마') || name.contains('埼玉')) {
      return '사이타마현';
    }
    // Chiba
    if (name.contains('chiba') || name.contains('치바') || name.contains('千葉')) {
      return '치바현';
    }
    // Ibaraki
    if (name.contains('ibaraki') || name.contains('이바라키') || name.contains('茨城')) {
      return '이바라키현';
    }
    // Tochigi
    if (name.contains('tochigi') || name.contains('토치기') || name.contains('栃木')) {
      return '토치기현';
    }
    // Gunma
    if (name.contains('gunma') || name.contains('군마') || name.contains('群馬')) {
      return '군마현';
    }
    // Yamanashi
    if (name.contains('yamanashi') || name.contains('야마나시') || name.contains('山梨')) {
      return '야마나시현';
    }
    // Nagano
    if (name.contains('nagano') || name.contains('나가노') || name.contains('長野') || name.contains('신슈') || name.contains('shinshu')) {
      return '나가노현';
    }
    // Shizuoka
    if (name.contains('shizuoka') || name.contains('시즈오카') || name.contains('静岡')) {
      return '시즈오카현';
    }
    // Aichi
    if (name.contains('aichi') || name.contains('아이치') || name.contains('愛知') || name.contains('nagoya') || name.contains('나고야')) {
      return '아이치현';
    }
    // Gifu
    if (name.contains('gifu') || name.contains('기후') || name.contains('岐阜')) {
      return '기후현';
    }
    // Mie
    if (name.contains('mie') || name.contains('미에') || name.contains('三重')) {
      return '미에현';
    }
    // Shiga
    if (name.contains('shiga') || name.contains('시가') || name.contains('滋賀')) {
      return '시가현';
    }
    // Kyoto
    if (name.contains('kyoto') || name.contains('교토') || name.contains('京都')) {
      return '교토부';
    }
    // Osaka
    if (name.contains('osaka') || name.contains('오사카') || name.contains('大阪')) {
      return '오사카부';
    }
    // Hyogo
    if (name.contains('hyogo') || name.contains('효고') || name.contains('兵庫') || name.contains('kobe') || name.contains('고베')) {
      return '효고현';
    }
    // Nara
    if (name.contains('nara') || name.contains('나라') || name.contains('奈良')) {
      return '나라현';
    }
    // Wakayama
    if (name.contains('wakayama') || name.contains('와카야마') || name.contains('和歌山')) {
      return '와카야마현';
    }
    // Fukui
    if (name.contains('fukui') || name.contains('후쿠이') || name.contains('福井')) {
      return '후쿠이현';
    }
    // Ishikawa
    if (name.contains('ishikawa') || name.contains('이시카와') || name.contains('石川') || name.contains('kanazawa') || name.contains('가나자와')) {
      return '이시카와현';
    }
    // Toyama
    if (name.contains('toyama') || name.contains('도야마') || name.contains('富山')) {
      return '도야마현';
    }
    // Niigata
    if (name.contains('niigata') || name.contains('니가타') || name.contains('新潟')) {
      return '니가타현';
    }
    // Fukushima
    if (name.contains('fukushima') || name.contains('후쿠시마') || name.contains('福島')) {
      return '후쿠시마현';
    }
    // Yamagata
    if (name.contains('yamagata') || name.contains('야마가타') || name.contains('山形')) {
      return '야마가타현';
    }
    // Miyagi
    if (name.contains('miyagi') || name.contains('미야기') || name.contains('宮城') || name.contains('sendai') || name.contains('센다이')) {
      return '미야기현';
    }
    // Iwate
    if (name.contains('iwate') || name.contains('이와테') || name.contains('岩手')) {
      return '이와테현';
    }
    // Akita
    if (name.contains('akita') || name.contains('아키타') || name.contains('秋田')) {
      return '아키타현';
    }
    // Aomori
    if (name.contains('aomori') || name.contains('아오모리') || name.contains('青森')) {
      return '아오모리현';
    }
    // Hokkaido
    if (name.contains('hokkaido') || name.contains('홉카이도') || name.contains('北海道') || name.contains('sapporo') || name.contains('삿포로')) {
      return '홉카이도';
    }
    // Tottori
    if (name.contains('tottori') || name.contains('돇토리') || name.contains('鳥取')) {
      return '돇토리현';
    }
    // Shimane
    if (name.contains('shimane') || name.contains('시마네') || name.contains('島根')) {
      return '시마네현';
    }
    // Okayama
    if (name.contains('okayama') || name.contains('오카야마') || name.contains('岡山')) {
      return '오카야마현';
    }
    // Hiroshima
    if (name.contains('hiroshima') || name.contains('히로시마') || name.contains('広島')) {
      return '히로시마현';
    }
    // Yamaguchi
    if (name.contains('yamaguchi') || name.contains('야마구치') || name.contains('山口')) {
      return '야마구치현';
    }
    // Tokushima
    if (name.contains('tokushima') || name.contains('도쿠시마') || name.contains('徳島')) {
      return '도쿠시마현';
    }
    // Kagawa
    if (name.contains('kagawa') || name.contains('가가와') || name.contains('香川')) {
      return '가가와현';
    }
    // Ehime
    if (name.contains('ehime') || name.contains('에히메') || name.contains('愛媛') || name.contains('matsuyama') || name.contains('마싰야마')) {
      return '에히메현';
    }
    // Kochi
    if (name.contains('kochi') || name.contains('고치') || name.contains('高知')) {
      return '고치현';
    }
    // Fukuoka
    if (name.contains('fukuoka') || name.contains('후쿠오카') || name.contains('福岡')) {
      return '후쿠오카현';
    }
    // Saga
    if (name.contains('saga') || name.contains('사가') || name.contains('佐賀')) {
      return '사가현';
    }
    // Nagasaki
    if (name.contains('nagasaki') || name.contains('나가사키') || name.contains('長崎')) {
      return '나가사키현';
    }
    // Kumamoto
    if (name.contains('kumamoto') || name.contains('구마모토') || name.contains('熊本')) {
      return '구마모토현';
    }
    // Oita
    if (name.contains('oita') || name.contains('오이타') || name.contains('大分')) {
      return '오이타현';
    }
    // Miyazaki
    if (name.contains('miyazaki') || name.contains('미야자키') || name.contains('宮崎')) {
      return '미야자키현';
    }
    // Kagoshima
    if (name.contains('kagoshima') || name.contains('가고시마') || name.contains('鹿児島')) {
      return '가고시마현';
    }
    // Okinawa
    if (name.contains('okinawa') || name.contains('오키나와') || name.contains('沖縄')) {
      return '오키나와현';
    }
    
    return regionName; // Return original if no match
  }

  @override
  void initState() {
    super.initState();
    // EN: Initialize favorites bootstrap
    // KO: 즐겨찾기 부트스트랩 초기화
    ref.read(favoritesBootstrapProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesPageProvider);
    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final selectedBandName = ref.watch(selectedBandNameProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: placesAsync.when(
            data: (page) => _buildPlacesContent(
              context,
              page.places,
              selectedProjectName,
              selectedBandName,
              theme,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorView(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesContent(
    BuildContext context,
    List<model.PlaceSummary> places,
    String? selectedProjectName,
    String? selectedBandName,
    ThemeData theme,
  ) {
    // EN: Filter places based on search query and region
    // KO: 검색 쿼리와 지역을 기반으로 장소 필터링
    var filteredPlaces = places;
    
    // EN: Filter by search query
    // KO: 검색 쿼리로 필터링
    if (_searchQuery.isNotEmpty) {
      filteredPlaces = filteredPlaces
          .where(
            (place) => place.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }
    
    // EN: Filter by selected region
    // KO: 선택된 지역으로 필터링
    if (_selectedRegion != null && _selectedRegion != '전체') {
      filteredPlaces = filteredPlaces
          .where(
            (place) {
              final regionName = place.regionSummary?.primaryName;
              if (regionName == null) return false;
              return _normalizePrefectureName(regionName) == _selectedRegion;
            },
          )
          .toList();
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        ref.invalidate(placesPageProvider);
        await ref.read(placesPageProvider.future);
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // EN: Header with project/band selection and search
          // KO: 프로젝트/밴드 선택 및 검색이 포함된 헤더
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              kSpacingMedium,
              kSpacingMedium,
              kSpacingMedium,
              kSpacingSmall,
            ),
            sliver: SliverToBoxAdapter(
              child: _buildHeaderCard(
                selectedProjectName,
                selectedBandName,
                theme,
              ),
            ),
          ),

          // EN: Search and view toggle controls
          // KO: 검색 및 뷰 전환 컨트롤
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            sliver: SliverToBoxAdapter(child: _buildSearchAndControls(theme)),
          ),

          // EN: Region filter buttons
          // KO: 지역 필터 버튼들
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: kSpacingMedium),
            sliver: SliverToBoxAdapter(child: _buildRegionFilters(places, theme)),
          ),

          // EN: Places grid or list
          // KO: 장소 그리드 또는 리스트
          if (filteredPlaces.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(_searchQuery.isNotEmpty),
            )
          else
            _isGridView
                ? _buildPlacesGrid(filteredPlaces)
                : _buildPlacesList(filteredPlaces),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    String? selectedProjectName,
    String? selectedBandName,
    ThemeData theme,
  ) {
    return FlowCard(
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.2),
          theme.colorScheme.secondary.withValues(alpha: 0.18),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Places', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: kSpacingXXSmall),
                    Text(
                      '성지와 라이브 장소를 탐험해보세요',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/places/map'),
                icon: const Icon(Icons.map_outlined),
                tooltip: '지도 보기',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpacingMedium),
          FlowPill(
            label: selectedProjectName ?? '전체 프로젝트',
            leading: const Icon(Icons.layers_outlined, size: 16),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            onTap: () => showProjectBandSelector(
              context,
              ref,
              onApplied: () => ref.invalidate(placesPageProvider),
            ),
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.72),
          ),
          if (selectedBandName != null) ...[
            const SizedBox(height: kSpacingSmall),
            FlowPill(
              label: selectedBandName,
              leading: const Icon(Icons.music_note_outlined, size: 16),
              backgroundColor: theme.colorScheme.secondary.withValues(
                alpha: 0.18,
              ),
              onTap: () => showProjectBandSelector(
                context,
                ref,
                onApplied: () => ref.invalidate(placesPageProvider),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchAndControls(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: kSpacingMedium),
        // EN: Search bar
        // KO: 검색 바
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '장소 이름으로 검색...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              prefixIcon: Semantics(
                label: '검색',
                child: const Icon(Icons.search_rounded),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.clear_rounded),
                      tooltip: '검색어 지우기',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: kSpacingMedium,
                vertical: kSpacingMedium,
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        // EN: View toggle
        // KO: 뷰 전환
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.grid_view_rounded, size: 18),
                  label: Text('Grid'),
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.view_list_rounded, size: 18),
                  label: Text('List'),
                ),
              ],
              selected: {_isGridView},
              onSelectionChanged: (selection) {
                setState(() => _isGridView = selection.first);
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegionFilters(List<model.PlaceSummary> places, ThemeData theme) {
    // EN: Extract unique regions from places
    // KO: 장소들에서 고유한 지역들을 추출
    final regions = <String>{};
    for (final place in places) {
      final regionName = place.regionSummary?.primaryName;
      if (regionName != null && regionName.isNotEmpty) {
        regions.add(regionName);
      }
    }
    
    // EN: Map regions to standardized prefecture names
    // KO: 지역을 표준화된 현 이름으로 매핑
    String _normalizePrefectureName(String regionName) {
      final name = regionName.toLowerCase();
      
      // Tokyo
      if (name.contains('tokyo') || name.contains('도쿄') || name.contains('東京')) {
        return '도쿄도';
      }
      // Kanagawa
      if (name.contains('kanagawa') || name.contains('가나가와') || name.contains('神奈川')) {
        return '가나가와현';
      }
      // Saitama
      if (name.contains('saitama') || name.contains('사이타마') || name.contains('埼玉')) {
        return '사이타마현';
      }
      // Chiba
      if (name.contains('chiba') || name.contains('치바') || name.contains('千葉')) {
        return '치바현';
      }
      // Ibaraki
      if (name.contains('ibaraki') || name.contains('이바라키') || name.contains('茨城')) {
        return '이바라키현';
      }
      // Tochigi
      if (name.contains('tochigi') || name.contains('토치기') || name.contains('栃木')) {
        return '토치기현';
      }
      // Gunma
      if (name.contains('gunma') || name.contains('군마') || name.contains('群馬')) {
        return '군마현';
      }
      // Yamanashi
      if (name.contains('yamanashi') || name.contains('야마나시') || name.contains('山梨')) {
        return '야마나시현';
      }
      // Nagano
      if (name.contains('nagano') || name.contains('나가노') || name.contains('長野') || name.contains('신슈') || name.contains('shinshu')) {
        return '나가노현';
      }
      // Shizuoka
      if (name.contains('shizuoka') || name.contains('시즈오카') || name.contains('静岡')) {
        return '시즈오카현';
      }
      // Aichi
      if (name.contains('aichi') || name.contains('아이치') || name.contains('愛知') || name.contains('nagoya') || name.contains('나고야')) {
        return '아이치현';
      }
      // Gifu
      if (name.contains('gifu') || name.contains('기후') || name.contains('岐阜')) {
        return '기후현';
      }
      // Mie
      if (name.contains('mie') || name.contains('미에') || name.contains('三重')) {
        return '미에현';
      }
      // Shiga
      if (name.contains('shiga') || name.contains('시가') || name.contains('滋賀')) {
        return '시가현';
      }
      // Kyoto
      if (name.contains('kyoto') || name.contains('교토') || name.contains('京都')) {
        return '교토부';
      }
      // Osaka
      if (name.contains('osaka') || name.contains('오사카') || name.contains('大阪')) {
        return '오사카부';
      }
      // Hyogo
      if (name.contains('hyogo') || name.contains('효고') || name.contains('兵庫') || name.contains('kobe') || name.contains('고베')) {
        return '효고현';
      }
      // Nara
      if (name.contains('nara') || name.contains('나라') || name.contains('奈良')) {
        return '나라현';
      }
      // Wakayama
      if (name.contains('wakayama') || name.contains('와카야마') || name.contains('和歌山')) {
        return '와카야마현';
      }
      // Fukui
      if (name.contains('fukui') || name.contains('후쿠이') || name.contains('福井')) {
        return '후쿠이현';
      }
      // Ishikawa
      if (name.contains('ishikawa') || name.contains('이시카와') || name.contains('石川') || name.contains('kanazawa') || name.contains('가나자와')) {
        return '이시카와현';
      }
      // Toyama
      if (name.contains('toyama') || name.contains('도야마') || name.contains('富山')) {
        return '도야마현';
      }
      // Niigata
      if (name.contains('niigata') || name.contains('니가타') || name.contains('新潟')) {
        return '니가타현';
      }
      // Fukushima
      if (name.contains('fukushima') || name.contains('후쿠시마') || name.contains('福島')) {
        return '후쿠시마현';
      }
      // Yamagata
      if (name.contains('yamagata') || name.contains('야마가타') || name.contains('山形')) {
        return '야마가타현';
      }
      // Miyagi
      if (name.contains('miyagi') || name.contains('미야기') || name.contains('宮城') || name.contains('sendai') || name.contains('센다이')) {
        return '미야기현';
      }
      // Iwate
      if (name.contains('iwate') || name.contains('이와테') || name.contains('岩手')) {
        return '이와테현';
      }
      // Akita
      if (name.contains('akita') || name.contains('아키타') || name.contains('秋田')) {
        return '아키타현';
      }
      // Aomori
      if (name.contains('aomori') || name.contains('아오모리') || name.contains('青森')) {
        return '아오모리현';
      }
      // Hokkaido
      if (name.contains('hokkaido') || name.contains('홋카이도') || name.contains('北海道') || name.contains('sapporo') || name.contains('삿포로')) {
        return '홋카이도';
      }
      // Tottori
      if (name.contains('tottori') || name.contains('돗토리') || name.contains('鳥取')) {
        return '돗토리현';
      }
      // Shimane
      if (name.contains('shimane') || name.contains('시마네') || name.contains('島根')) {
        return '시마네현';
      }
      // Okayama
      if (name.contains('okayama') || name.contains('오카야마') || name.contains('岡山')) {
        return '오카야마현';
      }
      // Hiroshima
      if (name.contains('hiroshima') || name.contains('히로시마') || name.contains('広島')) {
        return '히로시마현';
      }
      // Yamaguchi
      if (name.contains('yamaguchi') || name.contains('야마구치') || name.contains('山口')) {
        return '야마구치현';
      }
      // Tokushima
      if (name.contains('tokushima') || name.contains('도쿠시마') || name.contains('徳島')) {
        return '도쿠시마현';
      }
      // Kagawa
      if (name.contains('kagawa') || name.contains('가가와') || name.contains('香川')) {
        return '가가와현';
      }
      // Ehime
      if (name.contains('ehime') || name.contains('에히메') || name.contains('愛媛') || name.contains('matsuyama') || name.contains('마쓰야마')) {
        return '에히메현';
      }
      // Kochi
      if (name.contains('kochi') || name.contains('고치') || name.contains('高知')) {
        return '고치현';
      }
      // Fukuoka
      if (name.contains('fukuoka') || name.contains('후쿠오카') || name.contains('福岡')) {
        return '후쿠오카현';
      }
      // Saga
      if (name.contains('saga') || name.contains('사가') || name.contains('佐賀')) {
        return '사가현';
      }
      // Nagasaki
      if (name.contains('nagasaki') || name.contains('나가사키') || name.contains('長崎')) {
        return '나가사키현';
      }
      // Kumamoto
      if (name.contains('kumamoto') || name.contains('구마모토') || name.contains('熊本')) {
        return '구마모토현';
      }
      // Oita
      if (name.contains('oita') || name.contains('오이타') || name.contains('大分')) {
        return '오이타현';
      }
      // Miyazaki
      if (name.contains('miyazaki') || name.contains('미야자키') || name.contains('宮崎')) {
        return '미야자키현';
      }
      // Kagoshima
      if (name.contains('kagoshima') || name.contains('가고시마') || name.contains('鹿児島')) {
        return '가고시마현';
      }
      // Okinawa
      if (name.contains('okinawa') || name.contains('오키나와') || name.contains('沖縄')) {
        return '오키나와현';
      }
      
      return regionName; // Return original if no match
    }
    
    // EN: Convert regions to prefecture names and remove duplicates
    // KO: 지역을 현 이름으로 변환하고 중복 제거
    final prefectureNames = regions.map(_normalizePrefectureName).toSet();
    
    // EN: Define order from Tokyo (closest first)
    // KO: 도쿄부터 순서 정의 (가까운 순서)
    final prefectureOrder = [
      '도쿄도',
      '가나가와현',
      '사이타마현',
      '치바현',
      '이바라키현',
      '토치기현',
      '군마현',
      '야마나시현',
      '나가노현',
      '시즈오카현',
      '아이치현',
      '기후현',
      '미에현',
      '시가현',
      '교토부',
      '오사카부',
      '효고현',
      '나라현',
      '와카야마현',
      '후쿠이현',
      '이시카와현',
      '도야마현',
      '니가타현',
      '후쿠시마현',
      '야마가타현',
      '미야기현',
      '이와테현',
      '아키타현',
      '아오모리현',
      '홋카이도',
      '돗토리현',
      '시마네현',
      '오카야마현',
      '히로시마현',
      '야마구치현',
      '도쿠시마현',
      '가가와현',
      '에히메현',
      '고치현',
      '후쿠오카현',
      '사가현',
      '나가사키현',
      '구마모토현',
      '오이타현',
      '미야자키현',
      '가고시마현',
      '오키나와현',
    ];
    
    // EN: Sort prefectures based on distance from Tokyo
    // KO: 도쿄로부터의 거리에 따라 현 정렬
    final regionList = ['전체'];
    final sortedPrefectures = <String>[];
    
    // Add prefectures in order
    for (final prefecture in prefectureOrder) {
      if (prefectureNames.contains(prefecture)) {
        sortedPrefectures.add(prefecture);
      }
    }
    
    // Add any unmatched regions at the end
    for (final prefecture in prefectureNames) {
      if (!sortedPrefectures.contains(prefecture)) {
        sortedPrefectures.add(prefecture);
      }
    }
    
    regionList.addAll(sortedPrefectures);
    
    if (regionList.length <= 1) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kSpacingMedium),
        Text(
          '지역별 필터',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: kSpacingSmall),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: regionList.length,
            separatorBuilder: (_, __) => const SizedBox(width: kSpacingSmall),
            itemBuilder: (context, index) {
              final region = regionList[index];
              final isSelected = _selectedRegion == region || 
                               (_selectedRegion == null && region == '전체');
              
              return FilterChip(
                label: Text(region),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedRegion = region == '전체' ? null : region;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlacesGrid(List<model.PlaceSummary> places) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingMedium,
        kSpacingMedium,
        100,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: kSpacingMedium,
          mainAxisSpacing: kSpacingMedium,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final place = places[index];
          return _PlaceGridItem(place: place);
        }, childCount: places.length),
      ),
    );
  }

  Widget _buildPlacesList(List<model.PlaceSummary> places) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        kSpacingMedium,
        kSpacingMedium,
        kSpacingMedium,
        100,
      ),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          final place = places[index];
          return _PlaceListItem(place: place);
        },
        separatorBuilder: (_, __) => const SizedBox(height: kSpacingMedium),
        itemCount: places.length,
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.place_outlined,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: kSpacingMedium),
          Text(
            isSearching ? '검색 결과가 없습니다' : '표시할 장소가 없습니다',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: kSpacingXSmall),
          Text(
            isSearching ? '다른 검색어를 시도해보세요' : '프로젝트나 밴드를 선택해보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: kSpacingMedium),
            Text(
              '데이터를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingXSmall),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpacingMedium),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(placesPageProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Grid item widget for place display.
/// KO: 장소 표시를 위한 그리드 아이템 위젯.
class _PlaceGridItem extends ConsumerWidget {
  const _PlaceGridItem({required this.place});

  final model.PlaceSummary place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.place, place.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));

    final introText = place.introText;
    final regionText = place.regionSummary?.primaryName;

    return Semantics(
      label: '${place.name}, ${_getPlaceTypeLabel(place.type)} 장소',
      hint: '탭하여 상세 정보 보기',
      child: FlowCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/places/${place.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EN: Place image
            // KO: 장소 이미지
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  image: place.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(place.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: place.thumbnailUrl == null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.secondary.withValues(
                                alpha: 0.18,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getPlaceTypeIcon(place.type),
                            size: 32,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // EN: Place info
            // KO: 장소 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(kSpacingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and favorite button
                    Flexible(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: theme.textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _FavoriteButton(
                            isFavorite: isFavorite,
                            onToggle: () => _toggleFavorite(ref, place.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description text (optional)
                    if (introText != null && introText.isNotEmpty)
                      Flexible(
                        child: Text(
                          introText,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // Bottom row with region and type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Region info
                          if (regionText != null)
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      regionText,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 2),
                          // Place type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getPlaceTypeLabel(place.type),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String placeId) async {
    final controller = ref.read(favoriteControllerProvider);
    try {
      await controller.toggle(FavoriteEntityType.place, placeId);
    } catch (e) {
      // EN: Error handling - could show snackbar
      // KO: 오류 처리 - 스낵바를 표시할 수 있음
      debugPrint('Error toggling favorite: $e');
    }
  }
}

/// EN: List item widget for place display.
/// KO: 장소 표시를 위한 리스트 아이템 위젯.
class _PlaceListItem extends ConsumerWidget {
  const _PlaceListItem({required this.place});

  final model.PlaceSummary place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteKey = FavoriteKey(FavoriteEntityType.place, place.id);
    final isFavorite = ref.watch(isFavoriteProvider(favoriteKey));
    final introText = place.introText;
    final regionText = place.regionSummary?.primaryName;

    return Semantics(
      label: '${place.name}, ${_getPlaceTypeLabel(place.type)} 장소',
      hint: '탭하여 상세 정보 보기',
      child: FlowCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/places/${place.id}'),
        child: Row(
          children: [
            // EN: Place image
            // KO: 장소 이미지
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
                image: place.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(place.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: place.thumbnailUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.secondary.withValues(alpha: 0.18),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getPlaceTypeIcon(place.type),
                          size: 24,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // EN: Place info
            // KO: 장소 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _FavoriteButton(
                          isFavorite: isFavorite,
                          onToggle: () => _toggleFavorite(ref, place.id),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (introText != null && introText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        introText,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (regionText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.public, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              regionText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpacingXSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPlaceTypeLabel(place.type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(WidgetRef ref, String placeId) async {
    final controller = ref.read(favoriteControllerProvider);
    try {
      await controller.toggle(FavoriteEntityType.place, placeId);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }
}

/// EN: Animated favorite button widget.
/// KO: 애니메이션 즐겨찾기 버튼 위젯.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavorite, required this.onToggle});

  final bool isFavorite;
  final VoidCallback onToggle;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            onPressed: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onToggle();
            },
            icon: Icon(
              widget.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.isFavorite
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            iconSize: 18,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            tooltip: widget.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
          ),
        );
      },
    );
  }
}

// EN: Helper functions for place type icons and labels
// KO: 장소 타입 아이콘 및 라벨을 위한 헬퍼 함수들
IconData _getPlaceTypeIcon(model.PlaceType type) {
  switch (type) {
    case model.PlaceType.concertVenue:
      return Icons.mic_external_on_rounded;
    case model.PlaceType.cafeCollaboration:
      return Icons.local_cafe_rounded;
    case model.PlaceType.animeLocation:
      return Icons.movie_outlined;
    case model.PlaceType.characterShop:
      return Icons.storefront_rounded;
    case model.PlaceType.other:
      return Icons.location_city_rounded;
  }
}

String _getPlaceTypeLabel(model.PlaceType type) {
  switch (type) {
    case model.PlaceType.concertVenue:
      return '라이브';
    case model.PlaceType.cafeCollaboration:
      return '카페';
    case model.PlaceType.animeLocation:
      return '작중';
    case model.PlaceType.characterShop:
      return '샵';
    case model.PlaceType.other:
      return '기타';
  }
}
