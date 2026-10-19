# Quick Start Guide - Smart Orders Desktop

## ⚡ 5-Minute Setup

### 1. Prerequisites Check
```bash
# Verify Flutter is installed
flutter --version

# Should show: Flutter 3.x.x or higher
```

### 2. Enable Desktop Support
```bash
# Windows
flutter config --enable-windows-desktop

# macOS
flutter config --enable-macos-desktop

# Linux
flutter config --enable-linux-desktop
```

### 3. Install Dependencies
```bash
cd smart_orders_desktop
flutter pub get
```

### 4. Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 🔑 Test Login

**Email**: `john.smith@citymed.com`  
**Password**: `password`

## 🎯 First Steps

1. **Login** with credentials above
2. **Click "Create Order"** to open a new tab
3. **Add some products** from the left panel
4. **See real-time calculations** in the order table
5. **Click "Send Order"** to submit

## 📁 Project Structure

```
smart_orders_desktop/
├── lib/
│   ├── core/              # Core functionality
│   ├── features/          # Feature modules
│   │   ├── auth/         # Authentication
│   │   ├── orders/       # Order management
│   │   ├── reports/      # Reports
│   │   └── account/      # Account settings
│   └── main.dart         # App entry point
├── pubspec.yaml          # Dependencies
└── README.md             # Full documentation
```

## 🔧 Common Commands

```bash
# Clean build
flutter clean && flutter pub get

# Run with hot reload
flutter run -d windows

# Build for production
flutter build windows --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 🐛 Troubleshooting

### Build Errors
```bash
flutter clean
rm -rf build/
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Desktop Not Showing
```bash
flutter devices  # Check if desktop is listed
flutter doctor   # Check for issues
```

### State Not Updating
- Check if using `const` constructors
- Verify Riverpod providers are watching state
- Use `ref.watch()` not `ref.read()` in build methods

## 📚 Key Files to Explore

1. **`main.dart`** - App initialization
2. **`landing_screen.dart`** - Tab navigation system
3. **`create_order_screen.dart`** - Complete order workflow
4. **`mock_api_service.dart`** - Mock API implementation
5. **`app_theme.dart`** - UI styling

## 🚀 Next Steps

1. ✅ Run the app and test login
2. ✅ Test create order flow
3. ✅ Explore tab navigation
4. ⏳ Implement Order History screen
5. ⏳ Implement Reports screen
6. ⏳ Connect to real backend API

## 💡 Tips

- **Hot Reload**: Press `r` in terminal to hot reload changes
- **Mock Data**: All API calls use mock data by default
- **Multiple Tabs**: You can open multiple features simultaneously
- **Error Simulation**: Mock API has 10% random failure rate

## 🔗 Resources

- [Flutter Desktop Documentation](https://docs.flutter.dev/platform-integration/desktop)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Guide](https://pub.dev/packages/go_router)

## ✨ Features Ready to Use

- ✅ Complete authentication flow
- ✅ Tab-based navigation
- ✅ Create order with real-time calculations
- ✅ Product search and filters
- ✅ Order line management
- ✅ Pricing summary
- ✅ Mock API integration
- ⏳ Order history (placeholder)
- ⏳ Reports (placeholder)
- ⏳ Account settings (placeholder)

---

**Happy Coding! 🎉**

For detailed documentation, see `README.md` and `PROJECT_SUMMARY.md`
