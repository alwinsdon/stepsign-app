# StepSign Flutter Setup Script for Windows
# This script will guide you through Flutter installation

Write-Host "================================" -ForegroundColor Cyan
Write-Host "StepSign Flutter Setup" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is already installed
Write-Host "Checking for Flutter installation..." -ForegroundColor Yellow
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutterPath) {
    Write-Host "✓ Flutter is already installed!" -ForegroundColor Green
    flutter --version
    Write-Host ""
    
    # Get dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    flutter pub get
    
    Write-Host ""
    Write-Host "✓ Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run the app:" -ForegroundColor Cyan
    Write-Host "  flutter run" -ForegroundColor White
    Write-Host ""
    Write-Host "To build APK:" -ForegroundColor Cyan
    Write-Host "  flutter build apk --release" -ForegroundColor White
    
} else {
    Write-Host "✗ Flutter is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Download Flutter SDK:" -ForegroundColor Cyan
    Write-Host "   https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Extract to C:\src\flutter" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Add to PATH:" -ForegroundColor Cyan
    Write-Host "   C:\src\flutter\bin" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Run this script again" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OR use GitHub Actions to build without local install:" -ForegroundColor Yellow
    Write-Host "   See SETUP_WITHOUT_FLUTTER.md for details" -ForegroundColor White
    Write-Host ""
    
    # Ask if user wants to open download page
    $response = Read-Host "Open Flutter download page in browser? (y/n)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Start-Process "https://docs.flutter.dev/get-started/install/windows"
    }
}

Write-Host ""
Write-Host "For more help, see:" -ForegroundColor Yellow
Write-Host "  - SETUP_WITHOUT_FLUTTER.md (no Flutter install needed)" -ForegroundColor White
Write-Host "  - QUICKSTART.md (with Flutter installed)" -ForegroundColor White
Write-Host "  - README.md (project overview)" -ForegroundColor White
Write-Host ""

