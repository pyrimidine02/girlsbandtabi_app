import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:girlsbandtabi_app/screens/all/all_screen.dart';
import 'package:girlsbandtabi_app/screens/home/home_screen.dart';
import 'package:girlsbandtabi_app/screens/info/info_screen.dart';
import 'package:girlsbandtabi_app/screens/live/live_screen.dart';
import 'package:girlsbandtabi_app/screens/pilgrimage/pilgrimage_screen.dart';

import '../../providers/auth_provider.dart';
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
import '../../screens/auth/login_screen.dart';
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
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (isLoading) return '/'; // Show splash screen while loading

      // If user is not authenticated and not on a public route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If user is authenticated and on login or splash, redirect to home
      if (isAuthenticated && (isAuthRoute || state.matchedLocation == '/')) {
        return '/home';
      }

      return null; // No redirect needed
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
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
          // 성지
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pilgrimage',
                builder: (context, state) => const PilgrimageScreen(),
              ),
            ],
          ),
          // 라이브
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/live',
                builder: (context, state) => const LiveScreen(),
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
