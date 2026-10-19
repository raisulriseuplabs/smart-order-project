flutt# Smart Orders Desktop - Flutter Frontend

A comprehensive Flutter desktop application for Smart Orders system with full API integration and mock data support.

## Project Overview

This is a fully functional Flutter desktop frontend application that matches the provided UI designs exactly. The application is API-driven and includes mock API services for testing without a backend.

## Features Implemented

### ✅ Authentication Flow
- Splash screen with loading animation
- Login screen with form validation
- Registration request screen
- Forgot password screen
- Session management

### ✅ Landing Page
- Tab-based navigation system
- Dynamic tab creation and management
- User profile dropdown menu
- Welcome screen

### ✅ Create Order Screen (Comprehensive)
- Product list with search and filters
- Product selection and quantity management
- Order table with real-time calculations
- Insert/Edit order line modals
- Pricing summary (Total Saving, VAT, Total Inclusive)
- Send order functionality

### ✅ Additional Screens (Placeholders)
- Order History screen
- Reports screen
- Account settings screen

### ✅ Core Features
- API-driven architecture with mock services
- State management with Riverpod
- Responsive layouts for desktop
- Loading states and error handling
- Professional UI matching designs

## Tech Stack

- **Flutter**: 3.0+
- **State Management**: Riverpod 2.4.9
- **Routing**: GoRouter 13.0.0
- **API Layer**: Dio 5.4.0
- **Data Models**: Freezed + json_serializable
- **Local Storage**: SharedPreferences + Hive

## Project Structure

```
lib/
├── core/
│   ├── api/                    # API client and mock services
│   │   ├── api_client.dart
│   │   ├── api_response.dart
│   │   └── mock_api_service.dart
│   ├── constants/              # App constants and strings
│   │   └── app_constants.dart
│   ├── theme/                  # App theme and colors
│   │   └── app_theme.dart
│   └── router/                 # Navigation configuration
│       └── app_router.dart
├── features/
│   ├── auth/                   # Authentication feature
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── screens/
│   │   │   ├── splash_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   └── state/
│   │       └── auth_state.dart
│   ├── landing/                # Landing page with tabs
│   │   └── screens/
│   │       └── landing_screen.dart
│   ├── orders/                 # Order management
│   │   ├── models/
│   │   │   ├── product.dart
│   │   │   └── order.dart
│   │   └── screens/
│   │       ├── create_order_screen.dart
│   │       └── order_history_screen.dart
│   ├── reports/                # Reports feature
│   │   └── screens/
│   │       └── reports_screen.dart
│   └── account/                # Account settings
│       └── screens/
│           └── account_screen.dart
└── main.dart                   # App entry point
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK** (3.0 or higher)
   ```bash
   flutter --version
   ```

2. **Desktop Development**
   - **Windows**: Visual Studio 2022 with "Desktop development with C++" workload
   - **macOS**: Xcode and CocoaPods
   - **Linux**: Required build tools

   Enable desktop support:
   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

### Installation

1. **Navigate to project directory**
   ```bash
   cd smart_orders_desktop
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Freezed models)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   # Windows
   flutter run -d windows

   # macOS
   flutter run -d macos

   # Linux
   flutter run -d linux
   ```

## Mock API Usage

The application uses `MockApiService` for testing without a real backend. To switch to a real API:

1. Set `enableMockApi = false` in `lib/core/constants/app_constants.dart`
2. Update the `apiBaseUrl` in the same file
3. Implement real API endpoints to match the mock structure

### Mock Credentials

For testing the login:
- **Email**: `john.smith@citymed.com`
- **Password**: `password`

## Key Features

### API-Driven Architecture

All screens call APIs (mock or real) to:
- Load data
- Submit forms
- Handle errors
- Show loading states

### State Management

Uses Riverpod for:
- Authentication state
- API service providers
- User session management
- Widget state updates

### Tab Navigation

Landing page implements browser-like tabs:
- Each tab maintains its own state
- Tabs can be closed independently
- Welcome screen shows when no tabs are open

### Error Handling

Every API call includes:
- Try-catch blocks
- Loading indicators
- Error messages with Snackbars
- Network failure handling

## Expanding the Application

### Adding New Screens

1. Create screen file in appropriate feature folder
2. Add to tab navigation in `landing_screen.dart`
3. Implement API calls if needed

### Adding Real API Integration

1. Update `ApiClient` with real endpoints
2. Replace `MockApiService` calls with real API calls
3. Update models to match API response structure

### Implementing Missing Features

Order History, Reports, and Account screens are placeholders. To implement:

1. Create state management (Riverpod providers)
2. Add API service methods
3. Build UI components matching designs
4. Connect to API and handle responses

## Testing

Run tests:
```bash
flutter test
```

## Build for Production

### Windows
```bash
flutter build windows --release
```

### macOS
```bash
flutter build macos --release
```

### Linux
```bash
flutter build linux --release
```

## Notes

- The application matches the provided UI designs exactly
- All core flows are functional (Auth, Create Order)
- Mock API simulates real network delays and failures
- Tab system allows multiple concurrent workflows
- Ready for real API integration

## Next Steps

1. Generate Freezed models: `flutter pub run build_runner build`
2. Implement Order History screen with pagination
3. Implement Reports screen with date filters
4. Add Change Password dialog
5. Connect to real backend API
6. Add comprehensive error handling
7. Implement user preferences storage
8. Add PDF generation for orders

## Support

For issues or questions, refer to the PRD document or contact the development team.

---

**Powered by Riseup Labs**  
*Professional Flutter Development*
"# SmartOrder" 
# SmartOrder
