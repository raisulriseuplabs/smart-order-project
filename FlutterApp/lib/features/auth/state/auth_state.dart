import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smart_orders_desktop/features/auth/models/user.dart';
import 'package:smart_orders_desktop/features/auth/services/auth_service.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final user = await _authService.checkSession();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.login(email, password);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state is _Error) {
      state = const AuthState.unauthenticated();
    }
  }

  void updateUser(User user) {
    if (state is _Authenticated) {
      state = AuthState.authenticated(user);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<AsyncValue<User?>>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state.when(
    initial: () => const AsyncValue.loading(),
    loading: () => const AsyncValue.loading(),
    authenticated: (user) => AsyncValue.data(user),
    unauthenticated: () => const AsyncValue.data(null),
    error: (msg) => AsyncValue.error(msg, StackTrace.current),
  );
});
