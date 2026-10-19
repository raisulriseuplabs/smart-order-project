class AppConstants {
  // App Info
  static const String appName = 'Smart Orders';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Global Business Objects';
  static const String copyrightYear = '2009 - 2026';

  // API
  static const String apiBaseUrl = 'https://api.smartorders.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Local Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserData = 'user_data';
  static const String keyAppSettings = 'app_settings';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI
  static const double maxContentWidth = 1600;
  static const double sidebarWidth = 280;
  static const double headerHeight = 64;

  // Delays
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;

  // Features
  static const bool enableMockApi = true; // Set to false when using real API
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String landing = '/landing';
  static const String createOrder = '/create-order';
  static const String orderHistory = '/order-history';
  static const String reports = '/reports';
  static const String account = '/account';
}

class AppStrings {
  // Auth
  static const String login = 'Login';
  static const String register = 'Request Registration';
  static const String forgotPassword = 'Forgot Password?';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String rememberMe = 'Remember Me';
  static const String loginButton = 'Login';
  static const String exitButton = 'Exit';

  // Errors
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorInvalidCredentials = 'Invalid email or password';
  static const String errorRequired = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email';

  // Success
  static const String successLogin = 'Login successful';
  static const String successLogout = 'Logged out successfully';
  static const String successOrderCreated = 'Order created successfully';
  static const String successPasswordChanged = 'Password changed successfully';
}
