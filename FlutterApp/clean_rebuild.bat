@echo off
echo ========================================
echo  Smart Orders - Clean & Rebuild
echo ========================================
echo.

echo [1/3] Running flutter clean...
flutter clean
echo.

echo [2/3] Restoring dependencies...
flutter pub get
echo.

echo [3/3] Regenerating code (Freezed, JSON, etc.)...
dart run build_runner build --delete-conflicting-outputs
echo.

echo ========================================
echo  Done! All clean and rebuilt.
echo ========================================
pause
