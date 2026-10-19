import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_orders_desktop/core/constants/app_constants.dart';
import 'package:smart_orders_desktop/features/auth/state/auth_state.dart';
import 'package:smart_orders_desktop/features/auth/screens/splash_screen.dart';
import 'package:smart_orders_desktop/features/auth/screens/login_screen.dart';
import 'package:smart_orders_desktop/features/auth/screens/register_screen.dart';
import 'package:smart_orders_desktop/features/auth/screens/forgot_password_screen.dart';
import 'package:smart_orders_desktop/features/landing/screens/landing_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      return authState.when(
        initial: () => null,
        loading: () => isSplash ? null : AppRoutes.splash,
        authenticated: (_) =>
            isAuthRoute || isSplash ? AppRoutes.landing : null,
        unauthenticated: () => isAuthRoute ? null : AppRoutes.login,
        error: (_) => isAuthRoute ? null : AppRoutes.login,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.landing,
        builder: (context, state) => const LandingScreen(),
      ),
    ],
  );
});
