/// EN: GoRouter configuration with deep linking support
/// KO: 딥링크 지원을 포함한 GoRouter 구성
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';
import '../theme/gbt_animations.dart';
import '../../shared/main_scaffold.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/places/presentation/pages/places_map_page.dart';
import '../../features/places/presentation/pages/place_detail_page.dart';
import '../../features/live_events/presentation/pages/live_events_page.dart';
import '../../features/live_events/presentation/pages/live_event_detail_page.dart';
import '../../features/feed/presentation/pages/board_page.dart';
import '../../features/feed/presentation/pages/info_page.dart';
import '../../features/feed/presentation/pages/member_detail_page.dart';
import '../../features/feed/presentation/pages/news_detail_page.dart';
import '../../features/feed/presentation/pages/post_create_page.dart';
import '../../features/feed/presentation/pages/post_detail_page.dart';
import '../../features/feed/presentation/pages/unit_detail_page.dart';
import '../../features/projects/domain/entities/project_entities.dart'
    show Unit, UnitMember;
import '../../features/feed/presentation/pages/post_edit_page.dart';
import '../../features/feed/presentation/pages/travel_review_create_page.dart';
import '../../features/feed/presentation/pages/travel_review_detail_page.dart';
import '../../features/feed/presentation/pages/user_connections_page.dart';
import '../../features/feed/presentation/pages/user_profile_page.dart';
import '../../features/feed/domain/entities/feed_entities.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/community_settings_page.dart';
import '../../features/settings/presentation/pages/profile_edit_page.dart';
import '../../features/settings/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/account_tools_page.dart';
import '../../features/settings/presentation/pages/privacy_rights_page.dart';
import '../../features/settings/presentation/pages/consent_history_page.dart';
import '../../features/admin_ops/presentation/pages/admin_ops_page.dart';
import '../../features/visits/presentation/pages/visit_detail_page.dart';
import '../../features/visits/presentation/pages/visit_history_page.dart';
import '../../features/visits/presentation/pages/visit_stats_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

DateTime? _lastPostDetailNavigationAt;
String? _lastPostDetailNavigationPath;

Page<void> _buildAdaptiveDetailPage({
  required LocalKey key,
  required Widget child,
}) {
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    return MaterialPage<void>(key: key, child: child);
  }
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: GBTPageTransitions.fadeThrough(),
    transitionDuration: GBTAnimations.normal,
  );
}

Page<void> _buildAdaptiveOverlayPage({
  required LocalKey key,
  required Widget child,
}) {
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
    return MaterialPage<void>(key: key, child: child);
  }
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: GBTPageTransitions.sharedAxisY(),
    transitionDuration: GBTAnimations.normal,
  );
}

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
  static const String feed = 'feed';
  static const String discover = 'discover';
  static const String travelReviewTab = 'travel-review-tab';
  static const String places = 'places';
  static const String placeDetail = 'place-detail';
  static const String overlayPlaceDetail = 'overlay-place-detail';
  static const String live = 'live';
  static const String liveDetail = 'live-detail';
  static const String overlayLiveDetail = 'overlay-live-detail';
  static const String board = 'board';
  static const String info = 'info';
  static const String newsDetail = 'news-detail';
  static const String overlayNewsDetail = 'overlay-news-detail';
  static const String unitDetail = 'unit-detail';
  static const String memberDetail = 'member-detail';
  static const String postDetail = 'post-detail';
  static const String overlayPostDetail = 'overlay-post-detail';
  static const String postCreate = 'post-create';
  static const String travelReviewCreate = 'travelReviewCreate';
  static const String travelReviewDetail = 'travelReviewDetail';
  static const String postEdit = 'post-edit';
  static const String userProfile = 'user-profile';
  static const String userFollowers = 'user-followers';
  static const String userFollowing = 'user-following';

  // EN: Settings routes (overlay, outside shell)
  // KO: 설정 라우트 (오버레이, 쉘 외부)
  static const String settings = 'settings';
  static const String communitySettings = 'community-settings';
  static const String profileEdit = 'profile-edit';
  static const String notificationSettings = 'notification-settings';
  static const String accountTools = 'account-tools';
  static const String privacyRights = 'privacy-rights';
  static const String consentHistory = 'consent-history';
  static const String adminOps = 'admin-ops';
  static const String visitHistory = 'visit-history';
  static const String visitDetail = 'visit-detail';
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
  static const int board = 3;
  static const int info = 4;
}

/// EN: GoRouter provider with authentication redirect
/// KO: 인증 리다이렉트를 포함한 GoRouter 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      if (authState == AuthState.initial) {
        return null;
      }

      final isLoggedIn = authState == AuthState.authenticated;
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc == '/login' || loc == '/register' || loc.startsWith('/auth/');
      final isPublicRoute = loc == '/home' || loc.startsWith('/info');

      // EN: If logged in and on auth pages, redirect to home.
      // KO: 로그인했고 인증 페이지면 홈으로 리다이렉트.
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      // EN: If not logged in and trying to access protected routes, redirect
      // EN: to login with original destination.
      // KO: 비로그인 상태에서 보호된 경로 접근 시 원래 목적지와 함께
      // KO: 로그인 페이지로 리다이렉트.
      if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
        final redirectTo = Uri.encodeComponent(state.uri.toString());
        return '/login?redirect=$redirectTo';
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
                    pageBuilder: (context, state) {
                      final placeId = state.pathParameters['placeId']!;
                      return _buildAdaptiveDetailPage(
                        key: state.pageKey,
                        child: PlaceDetailPage(placeId: placeId),
                      );
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
                    pageBuilder: (context, state) {
                      final eventId = state.pathParameters['eventId']!;
                      return _buildAdaptiveDetailPage(
                        key: state.pageKey,
                        child: LiveEventDetailPage(eventId: eventId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // EN: Board Branch (Index 3)
          // KO: 게시판 분기 (인덱스 3)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/board',
                name: AppRoutes.board,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const BoardPage(initialTabIndex: 0),
                ),
                routes: [
                  GoRoute(
                    path: 'discover',
                    name: AppRoutes.discover,
                    pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const BoardPage(initialTabIndex: 1),
                    ),
                  ),
                  GoRoute(
                    path: 'travel-reviews-tab',
                    name: AppRoutes.travelReviewTab,
                    pageBuilder: (context, state) => NoTransitionPage(
                      key: state.pageKey,
                      child: const BoardPage(initialTabIndex: 2),
                    ),
                  ),
                  GoRoute(
                    path: 'posts/new',
                    name: AppRoutes.postCreate,
                    builder: (context, state) => const PostCreatePage(),
                  ),
                  GoRoute(
                    path: 'travel-review-create',
                    name: AppRoutes.travelReviewCreate,
                    builder: (context, state) => const TravelReviewCreatePage(),
                  ),
                  GoRoute(
                    path: 'travel-reviews/:reviewId',
                    name: AppRoutes.travelReviewDetail,
                    builder: (context, state) {
                      final reviewId = state.pathParameters['reviewId']!;
                      return TravelReviewDetailPage(reviewId: reviewId);
                    },
                  ),
                  GoRoute(
                    path: 'posts/:postId',
                    name: AppRoutes.postDetail,
                    builder: (context, state) {
                      final postId = state.pathParameters['postId']!;
                      final projectCodeHint =
                          state.uri.queryParameters['projectCode'];
                      return PostDetailPage(
                        postId: postId,
                        projectCodeHint: projectCodeHint,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'posts/:postId/edit',
                    name: AppRoutes.postEdit,
                    builder: (context, state) {
                      final post = state.extra;
                      if (post is! PostDetail) {
                        return const _InvalidNavigationPage(
                          message: '게시글 수정 경로 인자가 올바르지 않습니다.',
                        );
                      }
                      return PostEditPage(post: post);
                    },
                  ),
                ],
              ),
            ],
          ),

          // EN: Info Branch (Index 4)
          // KO: 정보 분기 (인덱스 4)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/info',
                name: AppRoutes.info,
                builder: (context, state) => const InfoPage(),
                routes: [
                  GoRoute(
                    path: 'news/:newsId',
                    name: AppRoutes.newsDetail,
                    pageBuilder: (context, state) {
                      final newsId = state.pathParameters['newsId']!;
                      return _buildAdaptiveDetailPage(
                        key: state.pageKey,
                        child: NewsDetailPage(newsId: newsId),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'units/:unitId',
                    name: AppRoutes.unitDetail,
                    pageBuilder: (context, state) {
                      final unit = state.extra;
                      if (unit is! Unit) {
                        return _buildAdaptiveDetailPage(
                          key: state.pageKey,
                          child: const _InvalidNavigationPage(
                            message: '유닛 상세 경로 인자가 올바르지 않습니다.',
                          ),
                        );
                      }
                      final projectId =
                          state.uri.queryParameters['projectId'] ?? '';
                      return _buildAdaptiveDetailPage(
                        key: state.pageKey,
                        child: UnitDetailPage(unit: unit, projectId: projectId),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'members/:memberId',
                        name: AppRoutes.memberDetail,
                        pageBuilder: (context, state) {
                          final extra = state.extra;
                          if (extra is! Map<String, dynamic>) {
                            return _buildAdaptiveDetailPage(
                              key: state.pageKey,
                              child: const _InvalidNavigationPage(
                                message: '멤버 상세 경로 인자가 올바르지 않습니다.',
                              ),
                            );
                          }
                          final member = extra['member'];
                          final unit = extra['unit'];
                          if (member is! UnitMember || unit is! Unit) {
                            return _buildAdaptiveDetailPage(
                              key: state.pageKey,
                              child: const _InvalidNavigationPage(
                                message: '멤버 상세 경로 인자가 올바르지 않습니다.',
                              ),
                            );
                          }
                          return _buildAdaptiveDetailPage(
                            key: state.pageKey,
                            child: MemberDetailPage(member: member, unit: unit),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // EN: Legacy route redirects
      // KO: 레거시 라우트 리다이렉트
      GoRoute(path: '/feed', redirect: (context, state) => '/board'),
      GoRoute(
        path: '/discover',
        redirect: (context, state) => '/board/discover',
      ),
      GoRoute(
        path: '/travel-reviews-tab',
        redirect: (context, state) => '/board/travel-reviews-tab',
      ),
      GoRoute(
        path: '/posts/new',
        redirect: (context, state) => '/board/posts/new',
      ),
      GoRoute(
        path: '/travel-reviews/create',
        redirect: (context, state) => '/board/travel-review-create',
      ),
      GoRoute(
        path: '/travel-reviews/:reviewId',
        redirect: (context, state) {
          final reviewId = state.pathParameters['reviewId']!;
          return '/board/travel-reviews/$reviewId';
        },
      ),
      GoRoute(
        path: '/posts/:postId',
        redirect: (context, state) {
          final postId = state.pathParameters['postId']!;
          return '/board/posts/$postId';
        },
      ),
      GoRoute(
        path: '/posts/:postId/edit',
        redirect: (context, state) {
          final postId = state.pathParameters['postId']!;
          return '/board/posts/$postId/edit';
        },
      ),

      // EN: Settings routes (overlay, outside shell)
      // KO: 설정 라우트 (오버레이, 쉘 외부)
      GoRoute(
        path: '/settings',
        name: AppRoutes.settings,
        pageBuilder: (context, state) {
          return _buildAdaptiveOverlayPage(
            key: state.pageKey,
            child: const SettingsPage(),
          );
        },
        routes: [
          GoRoute(
            path: 'profile',
            name: AppRoutes.profileEdit,
            builder: (context, state) => const ProfileEditPage(),
          ),
          GoRoute(
            path: 'notifications',
            name: AppRoutes.notificationSettings,
            builder: (context, state) => const NotificationSettingsPage(),
          ),
          GoRoute(
            path: 'account-tools',
            name: AppRoutes.accountTools,
            builder: (context, state) => const AccountToolsPage(),
          ),
          GoRoute(
            path: 'privacy-rights',
            name: AppRoutes.privacyRights,
            builder: (context, state) => const PrivacyRightsPage(),
          ),
          GoRoute(
            path: 'consents',
            name: AppRoutes.consentHistory,
            builder: (context, state) => const ConsentHistoryPage(),
          ),
          GoRoute(
            path: 'admin',
            name: AppRoutes.adminOps,
            builder: (context, state) => const AdminOpsPage(),
          ),
        ],
      ),

      // EN: Overlay routes (outside shell)
      // KO: 오버레이 라우트 (쉘 외부)
      GoRoute(
        path: '/community-settings',
        name: AppRoutes.communitySettings,
        builder: (context, state) => const CommunitySettingsPage(),
      ),
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
        path: '/live-attendance',
        redirect: (context, state) => '/visits?tab=live',
      ),

      // EN: Overlay detail routes used when opening details from overlay stacks
      // EN: (settings/favorites/visits/stats/notifications/search).
      // KO: 오버레이 스택(설정/즐겨찾기/방문/통계/알림/검색)에서 상세를 열 때
      // KO: 기존 오버레이 스택을 유지하기 위한 전용 상세 라우트입니다.
      GoRoute(
        path: '/overlay/places/:placeId',
        name: AppRoutes.overlayPlaceDetail,
        pageBuilder: (context, state) {
          final placeId = state.pathParameters['placeId']!;
          return _buildAdaptiveDetailPage(
            key: state.pageKey,
            child: PlaceDetailPage(placeId: placeId),
          );
        },
      ),
      GoRoute(
        path: '/overlay/live/:eventId',
        name: AppRoutes.overlayLiveDetail,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return _buildAdaptiveDetailPage(
            key: state.pageKey,
            child: LiveEventDetailPage(eventId: eventId),
          );
        },
      ),
      GoRoute(
        path: '/overlay/info/news/:newsId',
        name: AppRoutes.overlayNewsDetail,
        pageBuilder: (context, state) {
          final newsId = state.pathParameters['newsId']!;
          return _buildAdaptiveDetailPage(
            key: state.pageKey,
            child: NewsDetailPage(newsId: newsId),
          );
        },
      ),
      GoRoute(
        path: '/overlay/board/posts/:postId',
        name: AppRoutes.overlayPostDetail,
        pageBuilder: (context, state) {
          final postId = state.pathParameters['postId']!;
          final projectCodeHint = state.uri.queryParameters['projectCode'];
          return _buildAdaptiveDetailPage(
            key: state.pageKey,
            child: PostDetailPage(
              postId: postId,
              projectCodeHint: projectCodeHint,
            ),
          );
        },
      ),

      // EN: Visit routes (top-level overlays to avoid duplicate key with /settings)
      // KO: 방문 라우트 (중복 key 방지를 위해 /settings 외부의 최상위 오버레이)
      GoRoute(
        path: '/visits',
        name: AppRoutes.visitHistory,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initialTab = tab == 'live'
              ? VisitHistoryTab.live
              : VisitHistoryTab.places;
          return VisitHistoryPage(initialTab: initialTab);
        },
        routes: [
          GoRoute(
            path: ':visitId',
            name: AppRoutes.visitDetail,
            builder: (context, state) {
              final visitId = state.pathParameters['visitId']!;
              final placeId = state.uri.queryParameters['placeId'] ?? '';
              final visitedAt = state.uri.queryParameters['visitedAt'];
              final latStr = state.uri.queryParameters['latitude'];
              final lngStr = state.uri.queryParameters['longitude'];
              return VisitDetailPage(
                visitId: visitId,
                placeId: placeId,
                visitedAt: visitedAt,
                latitude: latStr != null ? double.tryParse(latStr) : null,
                longitude: lngStr != null ? double.tryParse(lngStr) : null,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/visit-stats',
        name: AppRoutes.visitStats,
        builder: (context, state) => const VisitStatsPage(),
      ),
      GoRoute(
        path: '/users/:userId',
        name: AppRoutes.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfilePage(userId: userId);
        },
        routes: [
          GoRoute(
            path: 'followers',
            name: AppRoutes.userFollowers,
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserConnectionsPage(
                userId: userId,
                initialTab: UserConnectionsTab.followers,
              );
            },
          ),
          GoRoute(
            path: 'following',
            name: AppRoutes.userFollowing,
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserConnectionsPage(
                userId: userId,
                initialTab: UserConnectionsTab.following,
              );
            },
          ),
        ],
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

class _InvalidNavigationPage extends StatelessWidget {
  const _InvalidNavigationPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

enum _ShellNavigationAction { push, go, none }

/// EN: Extension for navigation helpers
/// KO: 네비게이션 헬퍼 확장
extension AppRouterExtension on BuildContext {
  bool _isOverlayPath(String path) {
    return path.startsWith('/settings') ||
        path.startsWith('/favorites') ||
        path.startsWith('/visits') ||
        path.startsWith('/visit-stats') ||
        path.startsWith('/notifications') ||
        path.startsWith('/search') ||
        path.startsWith('/overlay');
  }

  String _resolveCurrentPathFromContext() {
    try {
      return GoRouterState.of(this).uri.path;
    } catch (_) {
      return GoRouter.of(this).routeInformationProvider.value.uri.path;
    }
  }

  bool _isInOverlayContext() {
    final contextPath = _resolveCurrentPathFromContext();
    final routerPath = GoRouter.of(
      this,
    ).routeInformationProvider.value.uri.path;
    return _isOverlayPath(contextPath) || _isOverlayPath(routerPath);
  }

  _ShellNavigationAction _resolveShellNavigationAction(String targetPath) {
    final contextPath = _resolveCurrentPathFromContext();
    final routerPath = GoRouter.of(
      this,
    ).routeInformationProvider.value.uri.path;
    final isSameTarget = contextPath == targetPath || routerPath == targetPath;
    final shouldUseGo =
        _isOverlayPath(contextPath) ||
        _isOverlayPath(routerPath) ||
        // EN: If target already exists in stack and this route can pop,
        // EN: prefer `go` to avoid pushing a duplicated page key.
        // KO: 타겟이 이미 스택에 있고 현재 라우트에서 pop 가능하면
        // KO: 중복 페이지 key push를 피하기 위해 `go`를 우선합니다.
        (isSameTarget && canPop());
    if (shouldUseGo) {
      return _ShellNavigationAction.go;
    }
    if (isSameTarget) {
      return _ShellNavigationAction.none;
    }
    // EN: Replace route from top-level overlays to shell branches to avoid
    // EN: stacking a second shell navigator that can render as a blank page.
    // KO: 최상위 오버레이에서 쉘 브랜치로 이동할 때 두 번째 쉘 네비게이터가
    // KO: 중첩되어 빈 화면으로 보이는 문제를 막기 위해 교체 이동(go)을 사용합니다.
    return _ShellNavigationAction.push;
  }

  /// EN: Navigate to place detail
  /// KO: 장소 상세로 이동
  void goToPlaceDetail(String placeId) {
    if (_isInOverlayContext()) {
      pushNamed(
        AppRoutes.overlayPlaceDetail,
        pathParameters: {'placeId': placeId},
      );
      return;
    }
    final router = GoRouter.of(this);
    final targetPath = router.namedLocation(
      AppRoutes.placeDetail,
      pathParameters: {'placeId': placeId},
    );
    switch (_resolveShellNavigationAction(targetPath)) {
      case _ShellNavigationAction.go:
        go(targetPath);
        return;
      case _ShellNavigationAction.none:
        return;
      case _ShellNavigationAction.push:
        pushNamed(AppRoutes.placeDetail, pathParameters: {'placeId': placeId});
        return;
    }
  }

  /// EN: Navigate to live event detail
  /// KO: 라이브 이벤트 상세로 이동
  void goToLiveDetail(String eventId) {
    if (_isInOverlayContext()) {
      pushNamed(
        AppRoutes.overlayLiveDetail,
        pathParameters: {'eventId': eventId},
      );
      return;
    }
    final router = GoRouter.of(this);
    final targetPath = router.namedLocation(
      AppRoutes.liveDetail,
      pathParameters: {'eventId': eventId},
    );
    switch (_resolveShellNavigationAction(targetPath)) {
      case _ShellNavigationAction.go:
        go(targetPath);
        return;
      case _ShellNavigationAction.none:
        return;
      case _ShellNavigationAction.push:
        pushNamed(AppRoutes.liveDetail, pathParameters: {'eventId': eventId});
        return;
    }
  }

  /// EN: Navigate to news detail
  /// KO: 뉴스 상세로 이동
  void goToNewsDetail(String newsId) {
    if (_isInOverlayContext()) {
      pushNamed(
        AppRoutes.overlayNewsDetail,
        pathParameters: {'newsId': newsId},
      );
      return;
    }
    final router = GoRouter.of(this);
    final targetPath = router.namedLocation(
      AppRoutes.newsDetail,
      pathParameters: {'newsId': newsId},
    );
    switch (_resolveShellNavigationAction(targetPath)) {
      case _ShellNavigationAction.go:
        go(targetPath);
        return;
      case _ShellNavigationAction.none:
        return;
      case _ShellNavigationAction.push:
        pushNamed(AppRoutes.newsDetail, pathParameters: {'newsId': newsId});
        return;
    }
  }

  /// EN: Navigate to unit detail page.
  /// KO: 유닛 상세 페이지로 이동.
  void goToUnitDetail({required Unit unit, required String projectId}) {
    pushNamed(
      AppRoutes.unitDetail,
      pathParameters: {'unitId': unit.id},
      queryParameters: {'projectId': projectId},
      extra: unit,
    );
  }

  /// EN: Navigate to member (character + VA) detail page.
  /// KO: 멤버(캐릭터 + 성우) 상세 페이지로 이동.
  void goToMemberDetail({
    required Unit unit,
    required UnitMember member,
    required String projectId,
  }) {
    pushNamed(
      AppRoutes.memberDetail,
      pathParameters: {'unitId': unit.id, 'memberId': member.id},
      queryParameters: {'projectId': projectId},
      extra: {'member': member, 'unit': unit},
    );
  }

  /// EN: Navigate to post detail
  /// KO: 게시글 상세로 이동
  void goToPostDetail(String postId, {String? projectCode}) {
    final trimmedProjectCode = projectCode?.trim();
    final Map<String, dynamic> queryParameters =
        trimmedProjectCode != null && trimmedProjectCode.isNotEmpty
        ? <String, String>{'projectCode': trimmedProjectCode}
        : <String, dynamic>{};
    if (_isInOverlayContext()) {
      final router = GoRouter.of(this);
      final targetPath = router.namedLocation(
        AppRoutes.overlayPostDetail,
        pathParameters: {'postId': postId},
        queryParameters: queryParameters,
      );
      final now = DateTime.now();
      final lastAt = _lastPostDetailNavigationAt;
      final currentLocation = router.routeInformationProvider.value.uri
          .toString();
      if (currentLocation == targetPath) {
        return;
      }
      if (lastAt != null &&
          _lastPostDetailNavigationPath == targetPath &&
          now.difference(lastAt).inMilliseconds < 700) {
        return;
      }
      _lastPostDetailNavigationAt = now;
      _lastPostDetailNavigationPath = targetPath;
      pushNamed(
        AppRoutes.overlayPostDetail,
        pathParameters: {'postId': postId},
        queryParameters: queryParameters,
      );
      return;
    }
    final router = GoRouter.of(this);
    final targetPath = router.namedLocation(
      AppRoutes.postDetail,
      pathParameters: {'postId': postId},
      queryParameters: queryParameters,
    );
    final navigationAction = _resolveShellNavigationAction(targetPath);
    final now = DateTime.now();
    final lastAt = _lastPostDetailNavigationAt;

    // EN: Prevent duplicate pushes caused by rapid multi-tap on the same item.
    // KO: 동일 아이템 연속 탭으로 인한 중복 push를 방지합니다.
    if (navigationAction == _ShellNavigationAction.none) {
      return;
    }
    if (lastAt != null &&
        _lastPostDetailNavigationPath == targetPath &&
        now.difference(lastAt).inMilliseconds < 700) {
      return;
    }

    _lastPostDetailNavigationAt = now;
    _lastPostDetailNavigationPath = targetPath;
    switch (navigationAction) {
      case _ShellNavigationAction.go:
        go(targetPath);
        return;
      case _ShellNavigationAction.none:
        return;
      case _ShellNavigationAction.push:
        pushNamed(
          AppRoutes.postDetail,
          pathParameters: {'postId': postId},
          queryParameters: queryParameters,
        );
        return;
    }
  }

  /// EN: Navigate to post creation.
  /// KO: 게시글 작성으로 이동
  void goToPostCreate() {
    pushNamed(AppRoutes.postCreate);
  }

  /// EN: Navigate to post edit.
  /// KO: 게시글 수정으로 이동
  void goToPostEdit(PostDetail post) {
    pushNamed(
      AppRoutes.postEdit,
      pathParameters: {'postId': post.id},
      extra: post,
    );
  }

  /// EN: Navigate to user profile.
  /// KO: 사용자 프로필로 이동
  void goToUserProfile(String userId) {
    pushNamed(AppRoutes.userProfile, pathParameters: {'userId': userId});
  }

  /// EN: Navigate to followers list.
  /// KO: 팔로워 목록으로 이동
  void goToUserFollowers(String userId) {
    pushNamed(AppRoutes.userFollowers, pathParameters: {'userId': userId});
  }

  /// EN: Navigate to following list.
  /// KO: 팔로잉 목록으로 이동
  void goToUserFollowing(String userId) {
    pushNamed(AppRoutes.userFollowing, pathParameters: {'userId': userId});
  }

  /// EN: Navigate to visit detail
  /// KO: 방문 상세로 이동
  void goToVisitDetail({
    required String visitId,
    required String placeId,
    String? visitedAt,
    double? latitude,
    double? longitude,
  }) {
    final queryParams = <String, String>{
      'placeId': placeId,
      if (visitedAt != null) 'visitedAt': visitedAt,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    };
    pushNamed(
      AppRoutes.visitDetail,
      pathParameters: {'visitId': visitId},
      queryParameters: queryParams,
    );
  }

  /// EN: Navigate to search with optional query
  /// KO: 선택적 쿼리와 함께 검색으로 이동
  void goToSearch([String? query]) {
    if (query != null) {
      pushNamed(AppRoutes.search, queryParameters: {'q': query});
    } else {
      pushNamed(AppRoutes.search);
    }
  }

  /// EN: Navigate to settings (push overlay on top of shell)
  /// KO: 설정으로 이동 (쉘 위에 오버레이로 push)
  void goToSettings() {
    final router = GoRouter.of(this);
    final currentUri = router.routeInformationProvider.value.uri;
    final settingsUri = Uri(
      path: '/settings',
      queryParameters: {'from': currentUri.toString()},
    );
    push(settingsUri.toString());
  }

  /// EN: Navigate to community settings.
  /// KO: 커뮤니티 설정으로 이동
  void goToCommunitySettings() {
    pushNamed(AppRoutes.communitySettings);
  }

  /// EN: Navigate to visit stats
  /// KO: 방문 통계로 이동
  void goToVisitStats() {
    pushNamed(AppRoutes.visitStats);
  }

  /// EN: Navigate to account tools.
  /// KO: 계정 도구로 이동
  void goToAccountTools() {
    pushNamed(AppRoutes.accountTools);
  }

  /// EN: Navigate to visit history
  /// KO: 방문 기록으로 이동
  void goToVisitHistory({bool showLiveTab = false}) {
    if (showLiveTab) {
      pushNamed(AppRoutes.visitHistory, queryParameters: const {'tab': 'live'});
      return;
    }
    pushNamed(AppRoutes.visitHistory);
  }
}
