/// EN: Main scaffold with bottom navigation for 5-tab structure
/// KO: 5탭 구조를 위한 하단 네비게이션을 포함한 메인 스캐폴드
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/navigation/gbt_bottom_nav.dart';

/// EN: Main scaffold widget with stateful navigation shell
/// KO: 상태 유지 네비게이션 쉘을 포함한 메인 스캐폴드 위젯
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: GBTBottomNav(
        items: const [
          GBTBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '홈',
          ),
          GBTBottomNavItem(
            icon: Icons.place_outlined,
            activeIcon: Icons.place,
            label: '장소',
          ),
          GBTBottomNavItem(
            icon: Icons.music_note_outlined,
            activeIcon: Icons.music_note,
            label: '라이브',
          ),
          GBTBottomNavItem(
            icon: Icons.article_outlined,
            activeIcon: Icons.article,
            label: '소식',
          ),
          GBTBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: '설정',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  /// EN: Handle bottom navigation tap
  /// KO: 하단 네비게이션 탭 처리
  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // EN: Navigate to initial location if tapping current tab
      // KO: 현재 탭을 탭하면 초기 위치로 이동
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
