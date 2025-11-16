import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:go_router/go_router.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        children: [
          // 헤더 섹션
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '커뮤니티',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/community/create'),
                        icon: const Icon(SFSymbols.plus_circle),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F7),
                          foregroundColor: const Color(0xFF007AFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 탭바
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF007AFF),
              unselectedLabelColor: const Color(0xFF8E8E93),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: '인기'),
                Tab(text: '최신'),
                Tab(text: '내 글'),
              ],
            ),
          ),

          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPopularPosts(),
                _buildLatestPosts(),
                _buildMyPosts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPosts() {
    final posts = [
      {
        'title': 'MyGO!!!!! 라이브 후기 🎸',
        'author': '락밴드팬',
        'content':
            '어제 라이브 정말 최고였어요! 무대 연출이 미쳤고 멤버들 실력도 대박이었습니다. 특히 토미오리 토가네의 기타 솔로는...',
        'likes': 142,
        'comments': 28,
        'time': '2시간 전',
        'isHot': true,
      },
      {
        'title': '성지순례 추천 코스 공유해요!',
        'author': '성덕이',
        'content':
            '하라주쿠-시부야-아키하바라 코스로 다녀왔습니다. 총 소요시간 6시간 정도였고, 중간중간 맛집도 많아서 좋았어요',
        'likes': 89,
        'comments': 35,
        'time': '5시간 전',
        'isHot': false,
      },
      {
        'title': 'Ave Mujica 새 앨범 리뷰',
        'author': '음악평론가',
        'content':
            '이번 앨범은 이전과는 다른 매력이 있네요. 다크한 분위기는 유지하면서도 멜로디가 더 대중적이 된 것 같아요',
        'likes': 76,
        'comments': 19,
        'time': '1일 전',
        'isHot': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF007AFF).withValues(alpha: 0.15),
                            const Color(0xFF007AFF).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        SFSymbols.person_circle,
                        color: Color(0xFF007AFF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post['author']! as String,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (post['isHot'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3B30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'HOT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            post['time']! as String,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF8E8E93)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(SFSymbols.ellipsis),
                      iconSize: 16,
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  post['title']! as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['content']! as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF3C3C43),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionButton(
                      SFSymbols.heart,
                      '${post['likes']}',
                      const Color(0xFFFF3B30),
                    ),
                    const SizedBox(width: 20),
                    _buildActionButton(
                      SFSymbols.bubble_left,
                      '${post['comments']}',
                      const Color(0xFF007AFF),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(SFSymbols.arrow_up),
                      iconSize: 18,
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLatestPosts() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(SFSymbols.clock, size: 64, color: Color(0xFF8E8E93)),
          SizedBox(height: 16),
          Text(
            '최신 게시글이 없습니다',
            style: TextStyle(fontSize: 17, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPosts() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(SFSymbols.person_circle, size: 64, color: Color(0xFF8E8E93)),
          SizedBox(height: 16),
          Text(
            '작성한 게시글이 없습니다',
            style: TextStyle(fontSize: 17, color: Color(0xFF8E8E93)),
          ),
          SizedBox(height: 8),
          Text(
            '첫 게시글을 작성해보세요!',
            style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
