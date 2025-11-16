import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/kt_theme.dart';
import 'features/auth/application/providers/auth_providers.dart';
import 'features/auth/presentation/pages/login_page.dart';

/// EN: Main application widget with Clean Architecture implementation
/// KO: Clean Architecture 구현을 포함한 메인 애플리케이션 위젯
class App extends ConsumerStatefulWidget {
  /// EN: Creates the main app instance
  /// KO: 메인 앱 인스턴스 생성
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    
    // EN: Check authentication status on app start
    // KO: 앱 시작시 인증 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '걸즈밴드타비',
      theme: KTTheme.lightTheme,
      darkTheme: KTTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      
      // EN: Use auth state to determine initial route
      // KO: 인증 상태를 사용해 초기 경로 결정
      home: Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authControllerProvider);
          
          return authState.when(
            initial: () => _buildSplashScreen(),
            loading: () => _buildSplashScreen(),
            authenticated: (user) => _buildHomeScreen(user.displayName),
            unauthenticated: () => const LoginPage(),
            error: (failure) => _buildErrorScreen(failure.message),
          );
        },
      ),
      
      // EN: Define named routes for navigation
      // KO: 네비게이션용 명명된 경로 정의
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => _buildHomeScreen('사용자'),
        '/register': (context) => _buildRegisterScreen(),
      },
    );
  }

  /// EN: Build splash/loading screen
  /// KO: 스플래시/로딩 화면 구성
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '걸즈밴드타비',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// EN: Build home screen (placeholder)
  /// KO: 홈 화면 구성 (자리 표시자)
  Widget _buildHomeScreen(String displayName) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('걸즈밴드타비'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              '환영합니다, $displayName님!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clean Architecture 구현이 성공적으로 작동하고 있습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }

  /// EN: Build error screen
  /// KO: 오류 화면 구성
  Widget _buildErrorScreen(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '오류가 발생했습니다',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).checkAuthStatus();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// EN: Build register screen (placeholder)
  /// KO: 등록 화면 구성 (자리 표시자)
  Widget _buildRegisterScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '회원가입 화면',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Text(
              '여기에 회원가입 폼이 구현될 예정입니다.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}