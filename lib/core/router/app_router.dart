/// EN: GoRouter configuration with deep linking support
/// KO: 딥링크 지원을 포함한 GoRouter 구성
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';
import '../../shared/main_scaffold.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/places/presentation/pages/places_map_page.dart';
import '../../features/places/presentation/pages/place_detail_page.dart';
import '../../features/live_events/presentation/pages/live_events_page.dart';
import '../../features/live_events/presentation/pages/live_event_detail_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/news_detail_page.dart';
import '../../features/feed/presentation/pages/post_create_page.dart';
import '../../features/feed/presentation/pages/post_detail_page.dart';
import '../../features/feed/presentation/pages/user_profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/profile_edit_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/visits/presentation/pages/visit_history_page.dart';
import '../../features/visits/presentation/pages/visit_stats_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

/// EN: Route names as constants
/// KO: 라우트 이름 상수
class AppRoutes {
  AppRoutes._();

  // EN: Auth routes
  // KO: 인증 라우트
  static const String login = 'login';
  static const String register = 'register';
  static const String oauthCallback = 'oauth-callback';

  // EN: Main tab routes
  // KO: 메인 탭 라우트
  static const String home = 'home';
  static const String places = 'places';
  static const String placeDetail = 'place-detail';
  static const String live = 'live';
  static const String liveDetail = 'live-detail';
  static const String feed = 'feed';
  static const String newsDetail = 'news-detail';
  static const String postDetail = 'post-detail';
  static const String postCreate = 'post-create';
  static const String userProfile = 'user-profile';
  static const String settings = 'settings';
  static const String profileEdit = 'profile-edit';
  static const String notificationSettings = 'notification-settings';
  static const String visitHistory = 'visit-history';
  static const String visitStats = 'visit-stats';

  // EN: Overlay routes
  // KO: 오버레이 라우트
  static const String search = 'search';
  static const String notifications = 'notifications';
  static const String favorites = 'favorites';
}

/// EN: Navigation shell branch index
/// KO: 네비게이션 쉘 분기 인덱스
class NavIndex {
  NavIndex._();

  static const int home = 0;
  static const int places = 1;
  static const int live = 2;
  static const int feed = 3;
  static const int settings = 4;
}

/// EN: GoRouter provider with authentication redirect
/// KO: 인증 리다이렉트를 포함한 GoRouter 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState == AuthState.authenticated;
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc == '/login' || loc == '/register' || loc.startsWith('/auth/');

      // EN: If logged in and on auth pages, redirect to home.
      // KO: 로그인했고 인증 페이지면 홈으로 리다이렉트.
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // EN: Auth routes (outside shell)
      // KO: 인증 라우트 (쉘 외부)
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/callback',
        name: AppRoutes.oauthCallback,
        builder: (context, state) {
          final provider = state.uri.queryParameters['provider'] ?? '';
          final code = state.uri.queryParameters['code'] ?? '';
          final stateParam = state.uri.queryParameters['state'];
          return OAuthCallbackPage(
            providerId: provider,
            code: code,
            stateParam: stateParam,
          );
        },
      ),

      // EN: Main app with bottom navigation shell
      // KO: 하단 네비게이션 쉘을 포함한 메인 앱
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // EN: Home Branch (Index 0)
          // KO: 홈 분기 (인덱스 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // EN: Places Branch (Index 1)
          // KO: 장소 분기 (인덱스 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/places',
                name: AppRoutes.places,
                builder: (context, state) => const PlacesMapPage(),
                routes: [
                  GoRoute(
                    path: ':placeId',
                    name: AppRoutes.placeDetail,
                    builder: (context, state) {
                      final placeId = state.pathParameters['placeId']!;
                      return PlaceDetailPage(placeId: placeId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // EN: Live Events Branch (Index 2)
          // KO: 라이브 이벤트 분기 (인덱스 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/live',
                name: AppRoutes.live,
                builder: (context, state) => const LiveEventsPage(),
                routes: [
                  GoRoute(
                    path: ':eventId',
                    name: AppRoutes.liveDetail,
                    builder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      return LiveEventDetailPage(eventId: eventId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // EN: Feed Branch (Index 3)
          // KO: 피드 분기 (인덱스 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feed',
                name: AppRoutes.feed,
                builder: (context, state) => const FeedPage(),
                routes: [
                  GoRoute(
                    path: 'news/:newsId',
                    name: AppRoutes.newsDetail,
                    builder: (context, state) {
                      final newsId = state.pathParameters['newsId']!;
                      return NewsDetailPage(newsId: newsId);
                    },
                  ),
                  GoRoute(
                    path: 'posts/new',
                    name: AppRoutes.postCreate,
                    builder: (context, state) => const PostCreatePage(),
                  ),
                  GoRoute(
                    path: 'posts/:postId',
                    name: AppRoutes.postDetail,
                    builder: (context, state) {
                      final postId = state.pathParameters['postId']!;
                      return PostDetailPage(postId: postId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // EN: Settings Branch (Index 4)
          // KO: 설정 분기 (인덱스 4)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'profile',
                    name: AppRoutes.profileEdit,
                    builder: (context, state) => const ProfileEditPage(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    name: AppRoutes.notificationSettings,
                    builder: (context, state) =>
                        const NotificationSettingsPage(),
                  ),
                  GoRoute(
                    path: 'visits',
                    name: AppRoutes.visitHistory,
                    builder: (context, state) => const VisitHistoryPage(),
                  ),
                  GoRoute(
                    path: 'stats',
                    name: AppRoutes.visitStats,
                    builder: (context, state) => const VisitStatsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // EN: Overlay routes (outside shell)
      // KO: 오버레이 라우트 (쉘 외부)
      GoRoute(
        path: '/search',
        name: AppRoutes.search,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/favorites',
        name: AppRoutes.favorites,
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/users/:userId',
        name: AppRoutes.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfilePage(userId: userId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// EN: Extension for navigation helpers
/// KO: 네비게이션 헬퍼 확장
extension AppRouterExtension on BuildContext {
  /// EN: Navigate to place detail
  /// KO: 장소 상세로 이동
  void goToPlaceDetail(String placeId) {
    goNamed(AppRoutes.placeDetail, pathParameters: {'placeId': placeId});
  }

  /// EN: Navigate to live event detail
  /// KO: 라이브 이벤트 상세로 이동
  void goToLiveDetail(String eventId) {
    goNamed(AppRoutes.liveDetail, pathParameters: {'eventId': eventId});
  }

  /// EN: Navigate to news detail
  /// KO: 뉴스 상세로 이동
  void goToNewsDetail(String newsId) {
    goNamed(AppRoutes.newsDetail, pathParameters: {'newsId': newsId});
  }

  /// EN: Navigate to post detail
  /// KO: 게시글 상세로 이동
  void goToPostDetail(String postId) {
    goNamed(AppRoutes.postDetail, pathParameters: {'postId': postId});
  }

  /// EN: Navigate to post creation.
  /// KO: 게시글 작성으로 이동
  void goToPostCreate() {
    goNamed(AppRoutes.postCreate);
  }

  /// EN: Navigate to user profile.
  /// KO: 사용자 프로필로 이동
  void goToUserProfile(String userId) {
    pushNamed(AppRoutes.userProfile, pathParameters: {'userId': userId});
  }

  /// EN: Navigate to search with optional query
  /// KO: 선택적 쿼리와 함께 검색으로 이동
  void goToSearch([String? query]) {
    if (query != null) {
      goNamed(AppRoutes.search, queryParameters: {'q': query});
    } else {
      goNamed(AppRoutes.search);
    }
  }
}
