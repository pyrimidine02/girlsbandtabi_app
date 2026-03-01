/// EN: Main scaffold with bottom navigation for 5-tab structure
/// KO: 5탭 구조를 위한 하단 네비게이션을 포함한 메인 스캐폴드
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/core_providers.dart';
import '../core/widgets/navigation/gbt_bottom_nav.dart';

/// EN: Main scaffold widget with stateful navigation shell
/// KO: 상태 유지 네비게이션 쉘을 포함한 메인 스캐폴드 위젯
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int? _lastSyncedIndex;
  bool _syncScheduled = false;
  DateTime? _lastBackPressed;

  void _scheduleSync(int index) {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted || _lastSyncedIndex == index) return;
      _lastSyncedIndex = index;
      ref.read(currentNavIndexProvider.notifier).state = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final canNavigateBack = GoRouter.of(context).canPop();
    if (_lastSyncedIndex != currentIndex) {
      _scheduleSync(currentIndex);
    }

    return PopScope(
      canPop: canNavigateBack,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || canNavigateBack) return;
        if (defaultTargetPlatform != TargetPlatform.android) {
          return;
        }
        final now = DateTime.now();
        if (_lastBackPressed != null &&
            now.difference(_lastBackPressed!) < const Duration(seconds: 2)) {
          SystemNavigator.pop();
          return;
        }
        _lastBackPressed = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("'뒤로' 버튼을 한 번 더 누르시면 종료됩니다"),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        body: widget.navigationShell,
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
              icon: Icons.forum_outlined,
              activeIcon: Icons.forum,
              label: '게시판',
            ),
            GBTBottomNavItem(
              icon: Icons.auto_stories_outlined,
              activeIcon: Icons.auto_stories,
              label: '정보',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }

  /// EN: Handle bottom navigation tap
  /// KO: 하단 네비게이션 탭 처리
  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      // EN: Navigate to initial location if tapping current tab
      // KO: 현재 탭을 탭하면 초기 위치로 이동
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    _lastSyncedIndex = index;
    ref.read(currentNavIndexProvider.notifier).state = index;
  }
}
