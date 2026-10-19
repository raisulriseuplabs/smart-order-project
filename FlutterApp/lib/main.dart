import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_orders_desktop/core/api/api_client.dart';
import 'package:smart_orders_desktop/core/api/mock_api_service.dart';
import 'package:smart_orders_desktop/core/theme/app_theme.dart';
import 'package:smart_orders_desktop/core/constants/app_constants.dart';
import 'package:smart_orders_desktop/features/auth/services/auth_service.dart';
import 'package:smart_orders_desktop/core/router/app_router.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_orders_desktop/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Must add this line.
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1600, 900),
      minimumSize: Size(380, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Smart Orders',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Mock API Service
  final mockApi = MockApiService();

  // Initialize API Client
  final apiClient = ApiClient(prefs);

  // Initialize Auth Service
  final authService = AuthService(mockApi, prefs);

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
        authServiceProvider.overrideWithValue(authService),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartOrdersApp(),
    ),
  );
}

class SmartOrdersApp extends ConsumerWidget {
  const SmartOrdersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);
    
    // Update system brightness
    themeNotifier.updateSystemBrightness(MediaQuery.platformBrightnessOf(context));
    
    final themeData = themeNotifier.getThemeData(MediaQuery.platformBrightnessOf(context));

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: themeData,
      routerConfig: router,
      builder: (context, child) {
        return AnimatedTheme(
          data: themeData,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child!,
        );
      },
    );
  }
}
