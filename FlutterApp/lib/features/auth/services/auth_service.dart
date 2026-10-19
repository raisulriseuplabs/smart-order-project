import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_orders_desktop/core/api/mock_api_service.dart';
import 'package:smart_orders_desktop/features/auth/models/user.dart';
import 'package:smart_orders_desktop/core/constants/app_constants.dart';

class AuthService {
  final MockApiService _api;
  final SharedPreferences _prefs;

  AuthService(this._api, this._prefs);

  Future<User?> getCurrentUser() async {
    final userData = _prefs.getString(AppConstants.keyUserData);
    if (userData == null) return null;

    try {
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = _prefs.getString(AppConstants.keyAuthToken);
    final user = await getCurrentUser();
    return token != null && user != null;
  }

  Future<User> login(String email, String password) async {
    final response = await _api.login(email, password);

    if (!response.success || response.data == null) {
      throw Exception(response.error ?? 'Login failed');
    }

    final token = response.data!['token'] as String;
    final user = User.fromJson(response.data!['user']);

    await _prefs.setString(AppConstants.keyAuthToken, token);
    await _prefs.setString(
      AppConstants.keyUserData,
      jsonEncode(user.toJson()),
    );

    return user;
  }

  Future<void> register({
    required String branch,
    required String account,
    required String name,
    required String email,
    String? phone,
  }) async {
    final response = await _api.register(
      branch: branch,
      account: account,
      name: name,
      email: email,
      phone: phone,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Registration failed');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await _api.forgotPassword(email);

    if (!response.success) {
      throw Exception(response.error ?? 'Request failed');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _api.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (!response.success) {
      throw Exception(response.error ?? 'Password change failed');
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyUserData);
  }

  Future<User?> checkSession() async {
    try {
      final response = await _api.checkSession();
      if (response.success && response.data != null) {
        final user = User.fromJson(response.data!['user']);
        await _prefs.setString(
          AppConstants.keyUserData,
          jsonEncode(user.toJson()),
        );
        return user;
      }
    } catch (e) {
      // Session invalid
    }
    return null;
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService must be initialized in main.dart');
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});
