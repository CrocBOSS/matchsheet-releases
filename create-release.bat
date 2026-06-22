@echo off
setlocal enabledelayedexpansion

REM Match Sheet Release Script
REM Usage: create-release.bat VERSION
REM Example: create-release.bat 1.0.1

if "%1"=="" (
    echo.
    echo Usage: create-release.bat VERSION
    echo Example: create-release.bat 1.0.1
    echo.
    exit /b 1
)

set VERSION=%1
set TAG_NAME=v%VERSION%

echo.
echo ========================================
echo   Match Sheet - Create Release %TAG_NAME%
echo ========================================
echo.

REM Step 1: Build APK
echo [1/4] Building release APK...
flutter build apk --release
if errorlevel 1 (
    echo ERROR: Failed to build APK
    exit /b 1
)
echo [DONE] APK built successfully
echo.

REM Step 2: Commit changes
echo [2/4] Committing changes to private repo...
git add .
git commit -m "Release %TAG_NAME%"
git push origin main
if errorlevel 1 (
    echo WARNING: Failed to push to origin ^(continuing^)
)
echo [DONE] Pushed to private repo
echo.

REM Step 3: Create and push tag
echo [3/4] Creating tag %TAG_NAME%...
git tag -a %TAG_NAME% -m "Release %TAG_NAME%"
if errorlevel 1 (
    echo ERROR: Failed to create tag
    echo TIP: Tag may already exist. Delete it with: git tag -d %TAG_NAME%
    exit /b 1
)
echo [DONE] Tag created
echo.

echo [4/4] Pushing tag to releases repo...
git push releases %TAG_NAME%
if errorlevel 1 (
    echo ERROR: Failed to push tag to releases repo
    echo.
    echo Make sure you have added the releases remote:
    echo   git remote add releases https://github.com/YOUR_USERNAME/YOUR_RELEASES_REPO.git
    echo.
    exit /b 1
)
echo [DONE] Tag pushed to releases repo
echo.

REM Step 4: Open locations
echo.
echo ========================================
echo SUCCESS! Release %TAG_NAME% created
echo ========================================
echo.
echo NEXT STEPS:
echo 1. Go to your GitHub releases repository
echo 2. Create a new release with tag: %TAG_NAME%
echo 3. Upload APK from: build\app\outputs\flutter-apk\app-release.apk
echo 4. Write release notes
echo 5. Click "Publish release"
echo.

REM Open APK folder
start explorer build\app\outputs\flutter-apk

echo.
echo APK folder opened. Press any key to exit...
pause >nul
