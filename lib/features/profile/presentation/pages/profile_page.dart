import 'package:flutter/material.dart';

import '../../../../core/theme/kt_colors.dart';

/// EN: User profile page showing profile information and settings
/// KO: 프로필 정보와 설정을 보여주는 사용자 프로필 페이지
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: KTColors.accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // EN: Navigate to settings
              // KO: 설정으로 이동
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // EN: Profile header
            // KO: 프로필 헤더
            _ProfileHeader(),

            SizedBox(height: 24),

            // EN: Statistics cards
            // KO: 통계 카드들
            _StatisticsSection(),

            SizedBox(height: 24),

            // EN: Menu items
            // KO: 메뉴 항목들
            _MenuSection(),
          ],
        ),
      ),
    );
  }
}

/// EN: Profile header widget with avatar and basic info
/// KO: 아바타와 기본 정보가 있는 프로필 헤더 위젯
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // EN: Avatar
            // KO: 아바타
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: KTColors.accent,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // EN: Name and email
            // KO: 이름과 이메일
            const Text(
              'User Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 16),

            // EN: Edit profile button
            // KO: 프로필 편집 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // EN: Navigate to edit profile
                  // KO: 프로필 편집으로 이동
                },
                child: const Text('프로필 편집'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Statistics section showing user activity
/// KO: 사용자 활동을 보여주는 통계 섹션
class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '활동 통계',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '방문한 장소',
                value: '12',
                icon: Icons.place,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '참석한 이벤트',
                value: '8',
                icon: Icons.event,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '업로드한 사진',
                value: '24',
                icon: Icons.photo,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: '즐겨찾기',
                value: '15',
                icon: Icons.favorite,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// EN: Statistics card widget
/// KO: 통계 카드 위젯
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Menu section with navigation options
/// KO: 네비게이션 옵션이 있는 메뉴 섹션
class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _MenuItem(
                icon: Icons.history,
                title: '방문 기록',
                onTap: () {
                  // EN: Navigate to visit history
                  // KO: 방문 기록으로 이동
                },
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.favorite,
                title: '즐겨찾기',
                onTap: () {
                  // EN: Navigate to favorites
                  // KO: 즐겨찾기로 이동
                },
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.settings,
                title: '설정',
                onTap: () {
                  // EN: Navigate to settings
                  // KO: 설정으로 이동
                },
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.help_outline,
                title: '도움말',
                onTap: () {
                  // EN: Navigate to help
                  // KO: 도움말로 이동
                },
              ),
              const Divider(height: 1),
              _MenuItem(
                icon: Icons.info_outline,
                title: '앱 정보',
                onTap: () {
                  // EN: Navigate to app info
                  // KO: 앱 정보로 이동
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// EN: Menu item widget
/// KO: 메뉴 항목 위젯
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
