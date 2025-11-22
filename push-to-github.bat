@echo off
echo ========================================
echo StepSign Flutter App - GitHub Push Script
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed!
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo Git is installed. Proceeding...
echo.

REM Initialize git repository if not already done
if not exist ".git" (
    echo Initializing Git repository...
    git init
    echo.
)

REM Add all files
echo Adding all files to Git...
git add .
echo.

REM Commit
echo Committing files...
git commit -m "Complete Flutter implementation - All 9 screens with exact Figma aesthetics"
echo.

REM Instructions for GitHub
echo ========================================
echo NEXT STEPS:
echo ========================================
echo.
echo 1. Go to https://github.com/new
echo 2. Create a new repository (e.g., "stepsign-flutter-app")
echo 3. Copy the repository URL (e.g., https://github.com/YOUR_USERNAME/stepsign-flutter-app.git)
echo 4. Run this command (replace with your URL):
echo.
echo    git remote add origin https://github.com/YOUR_USERNAME/stepsign-flutter-app.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo ========================================
echo.

pause

