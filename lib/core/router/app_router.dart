import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:girlsbandtabi_app/screens/all/all_screen.dart';
import 'package:girlsbandtabi_app/screens/home/home_screen.dart';
import 'package:girlsbandtabi_app/screens/info/info_screen.dart';
import 'package:girlsbandtabi_app/screens/places/place_list_screen.dart';
import 'package:girlsbandtabi_app/screens/places/place_map_screen.dart';
import '../../features/live_events/presentation/pages/live_events_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

import '../../features/auth/application/providers/auth_providers.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_analytics_screen.dart';
import '../../screens/admin/admin_media_deletions_screen.dart';
import '../../screens/admin/admin_exports_screen.dart';
import '../../screens/admin/admin_tokens_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/admin/admin_audit_logs_screen.dart';
import '../../screens/admin/bands_admin_screen.dart';
import '../../screens/admin/live_events_admin_screen.dart';
import '../../screens/admin/news_admin_screen.dart';
import '../../screens/admin/places_admin_screen.dart';
import '../../screens/admin/projects_admin_screen.dart';
import '../../screens/admin/roles_admin_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/legal/privacy_screen.dart';
import '../../screens/legal/terms_screen.dart';
import '../../screens/live/live_detail_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/news/news_detail_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/places/place_detail_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/uploads/my_uploads_screen.dart';

// Root navigator key
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      // EN: Check authentication state using the new auth controller
      // KO: 새로운 인증 컨트롤러를 사용하여 인증 상태 확인
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      return authState.when(
        initial: () => '/', // EN: Show splash while checking / KO: 확인하는 동안 스플래시 표시
        loading: () => '/', // EN: Show splash during loading / KO: 로딩 중 스플래시 표시
        authenticated: (_) {
          // EN: If authenticated and on auth route, go to home / KO: 인증되었고 인증 경로에 있으면 홈으로 이동
          if (isAuthRoute || state.matchedLocation == '/') {
            return '/home';
          }
          return null; // EN: No redirect needed / KO: 리디렉션 불필요
        },
        unauthenticated: () {
          // EN: If not authenticated and not on auth route, go to login / KO: 인증되지 않았고 인증 경로에 없으면 로그인으로 이동
          if (!isAuthRoute) {
            return '/login';
          }
          return null; // EN: No redirect needed / KO: 리디렉션 불필요
        },
        error: (_) {
          // EN: On error, redirect to login / KO: 오류시 로그인으로 리디렉션
          if (!isAuthRoute) {
            return '/login';
          }
          return null; // EN: No redirect needed / KO: 리디렉션 불필요
        },
      );
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/places/:placeId',
        builder: (context, state) =>
            PlaceDetailScreen(placeId: state.pathParameters['placeId']!),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Main application shell with 5 tabs: 홈, 성지, 라이브, 정보, 전체
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // 홈
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Places (성지)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/places',
                builder: (context, state) => const PlaceListScreen(),
                routes: [
                  GoRoute(
                    path: 'map',
                    builder: (context, state) {
                      final placeId = state.uri.queryParameters['placeId'];
                      return PlaceMapScreen(initialPlaceId: placeId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 라이브
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/live',
                builder: (context, state) => const LiveEventsListPage(),
              ),
            ],
          ),
          // 정보 (커뮤니티 포함)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/info',
                builder: (context, state) => const InfoScreen(),
              ),
            ],
          ),
          // 전체
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/all',
                builder: (context, state) => const AllScreen(),
              ),
            ],
          ),
        ],
      ),
      // Admin routes
      GoRoute(
        path: '/admin/places',
        builder: (context, state) => const PlacesAdminScreen(),
      ),
      GoRoute(
        path: '/admin/projects',
        builder: (context, state) => const ProjectsAdminScreen(),
      ),
      GoRoute(
        path: '/admin/roles',
        builder: (context, state) => const RolesAdminScreen(),
      ),
      GoRoute(
        path: '/admin/news',
        builder: (context, state) => const NewsAdminScreen(),
      ),
      GoRoute(
        path: '/admin/bands',
        builder: (context, state) => const BandsAdminScreen(),
      ),
      GoRoute(
        path: '/admin/live-events',
        builder: (context, state) => const LiveEventsAdminScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/media-deletions',
        builder: (context, state) => const AdminMediaDeletionsScreen(),
      ),
      GoRoute(
        path: '/admin/exports',
        builder: (context, state) => const AdminExportsScreen(),
      ),
      GoRoute(
        path: '/admin/tokens',
        builder: (context, state) => const AdminTokensScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/audit-logs',
        builder: (context, state) => const AdminAuditLogsScreen(),
      ),
      // Simple placeholders for frequently used misc pages
      GoRoute(
        path: '/settings',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('설정 (준비중)'))),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('도움말 (준비중)'))),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('문의하기 (준비중)'))),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('앱 정보 (준비중)'))),
      ),
      GoRoute(
        path: '/uploads/my',
        builder: (context, state) => const MyUploadsScreen(),
      ),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/news/:newsId',
        builder: (context, state) =>
            NewsDetailScreen(newsId: state.pathParameters['newsId']!),
      ),
      GoRoute(
        path: '/live/:liveEventId',
        builder: (context, state) =>
            LiveDetailScreen(liveEventId: state.pathParameters['liveEventId']!),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: const Text('데이터가 없습니다.'))),
  );
});
