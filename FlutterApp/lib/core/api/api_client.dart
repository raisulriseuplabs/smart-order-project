import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.smartorders.com/v1', // Mock base URL
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = _prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 - Unauthorized
          if (error.response?.statusCode == 401) {
            await _prefs.remove('auth_token');
            await _prefs.remove('user_data');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    await _prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient must be initialized in main.dart');
});
