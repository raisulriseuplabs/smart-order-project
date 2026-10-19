import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  ocean,
  emerald,
  indigo,
  sunset,
  slate,
  midnight,
  lavender,
  cyan,
  neutral,
  auto,
}

class ThemeState {
  final AppThemeMode mode;
  final Color customSeedColor;
  final bool useMaterialYou;

  ThemeState({
    required this.mode,
    required this.customSeedColor,
    this.useMaterialYou = false,
  });

  ThemeState copyWith({
    AppThemeMode? mode,
    Color? customSeedColor,
    bool? useMaterialYou,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      customSeedColor: customSeedColor ?? this.customSeedColor,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _modeKey = 'theme_mode';
  static const String _colorKey = 'theme_custom_color';
  static const String _materialYouKey = 'theme_material_you';
  
  final SharedPreferences? _prefs;
  Brightness? _systemBrightness;

  ThemeNotifier(this._prefs) : super(ThemeState(
    mode: AppThemeMode.ocean,
    customSeedColor: const Color(0xFF0F6E8C),
  )) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;

    final modeName = _prefs!.getString(_modeKey);
    final colorValue = _prefs!.getInt(_colorKey);
    final useMaterialYou = _prefs!.getBool(_materialYouKey) ?? false;

    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => AppThemeMode.ocean,
    );

    state = ThemeState(
      mode: mode,
      customSeedColor: colorValue != null ? Color(colorValue) : const Color(0xFF0F6E8C),
      useMaterialYou: useMaterialYou,
    );
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
    _prefs?.setString(_modeKey, mode.name);
  }

  void setUseMaterialYou(bool value) {
    state = state.copyWith(useMaterialYou: value);
    _prefs?.setBool(_materialYouKey, value);
  }

  void updateSystemBrightness(Brightness brightness) {
    if (_systemBrightness != brightness) {
      _systemBrightness = brightness;
      if (state.mode == AppThemeMode.auto) {
        state = state.copyWith(); // Trigger rebuild
      }
    }
  }

  ThemeData getThemeData(Brightness brightness) {
    final seed = _getSeedColor(brightness);
    final isDark = _determineIsDark(brightness);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? const Color(0xFF111827) : null,
      onSurface: isDark ? Colors.white : null,
      onSurfaceVariant: isDark ? const Color(0xFF94A3B8) : null,
      outline: isDark ? const Color(0xFF334155) : null,
      outlineVariant: isDark ? const Color(0xFF1E293B) : null,
    );

    final themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F172A) : colorScheme.surfaceContainerLow,
      
      // Global Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0F172A) : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E293B) : colorScheme.surface,
        elevation: 2,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.05 : 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // Animation parameters
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return themeData;
  }

  Color _getSeedColor(Brightness contextBrightness) {
    switch (state.mode) {
      case AppThemeMode.ocean: return const Color(0xFF0F6E8C);
      case AppThemeMode.emerald: return const Color(0xFF1E7F5C);
      case AppThemeMode.indigo: return const Color(0xFF3F51B5);
      case AppThemeMode.sunset: return const Color(0xFFFF6B6B);
      case AppThemeMode.slate: return const Color(0xFF475569);
      case AppThemeMode.midnight: return const Color(0xFF1E293B);
      case AppThemeMode.lavender: return const Color(0xFF8B5CF6);
      case AppThemeMode.cyan: return const Color(0xFF0891B2);
      case AppThemeMode.neutral: return const Color(0xFF737373);
      case AppThemeMode.auto:
        return (contextBrightness == Brightness.dark) 
            ? const Color(0xFF1E293B) 
            : const Color(0xFF0F6E8C);
    }
  }

  bool _determineIsDark(Brightness contextBrightness) {
    if (state.mode == AppThemeMode.midnight) return true;
    if (state.mode == AppThemeMode.auto) return contextBrightness == Brightness.dark;
    return false;
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

