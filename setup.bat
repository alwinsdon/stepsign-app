@echo off
echo ================================
echo StepSign Flutter Setup
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Flutter is installed!
    flutter --version
    echo.
    echo Installing dependencies...
    flutter pub get
    echo.
    echo ================================
    echo Setup Complete!
    echo ================================
    echo.
    echo To run the app:
    echo   flutter run
    echo.
    echo To build APK:
    echo   flutter build apk --release
    echo.
) else (
    echo [ERROR] Flutter is not installed
    echo.
    echo Please install Flutter first:
    echo.
    echo 1. Download from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\src\flutter
    echo 3. Add C:\src\flutter\bin to PATH
    echo 4. Restart terminal and run this script again
    echo.
    echo OR use GitHub Actions to build without local install
    echo See SETUP_WITHOUT_FLUTTER.md for details
    echo.
    pause
)

