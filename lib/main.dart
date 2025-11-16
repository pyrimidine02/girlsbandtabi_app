import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'core/network/network_client.dart';
import 'core/providers/core_providers.dart' as core_providers;
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/auth/application/providers/auth_providers.dart' as auth_providers;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  const secureStorage = FlutterSecureStorage();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.path;
        final isAuthEndpoint = path.contains('/auth/login') ||
            path.contains('/auth/register') ||
            path.contains('/auth/refresh');
        if (!isAuthEndpoint) {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      logPrint: (object) => debugPrint(object.toString()),
    ),
  );

  final networkClient = DioNetworkClient(
    dio: dio,
    defaultDecoder: (data) {
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is List) {
        return {'data': data};
      }
      return {'value': data};
    },
  );

  runApp(
    ProviderScope(
      overrides: [
        core_providers.sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        auth_providers.sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        auth_providers.networkClientProvider.overrideWithValue(networkClient),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(auth_providers.authControllerProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final router = ref.watch(routerProvider);
    // Initialize selection persistence (load + watch changes)
    ref.watch(core_providers.selectionPersistenceManagerProvider);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.lightTextTheme,
      colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      onPrimary: Colors.white,
      secondary: AppColors.lightAccentSecondary,
      onSecondary: AppColors.lightTextPrimary,
      tertiary: AppColors.lightAccentTertiary,
      onTertiary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.lightError,
      onError: Colors.white,
    ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightCardOutline),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.lightAccent.withValues(alpha: 0.12),
        secondarySelectedColor: AppColors.lightAccent,
        labelStyle: AppTypography.lightTextTheme.labelLarge!,
        secondaryLabelStyle:
            AppTypography.lightTextTheme.labelLarge!.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.lightAccent,
        scaffoldBackgroundColor: AppColors.lightBackground,
        barBackgroundColor: Color(0xF2FFFFFF),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.darkTextTheme,
      colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccentSecondary,
      onPrimary: Colors.black,
      secondary: AppColors.darkAccent,
      onSecondary: Colors.black,
      tertiary: AppColors.darkAccentTertiary,
      onTertiary: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.darkError,
      onError: Colors.black,
    ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardOutline),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.darkTextSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        selectedColor: AppColors.darkAccentSecondary.withValues(alpha: 0.18),
        secondarySelectedColor: AppColors.darkAccent,
        labelStyle: AppTypography.darkTextTheme.labelLarge!,
        secondaryLabelStyle:
            AppTypography.darkTextTheme.labelLarge!.copyWith(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.darkAccent,
        scaffoldBackgroundColor: AppColors.darkBackground,
        barBackgroundColor: Color(0xCC141A29),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.darkTextPrimary,
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: '걸즈밴드타비',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
