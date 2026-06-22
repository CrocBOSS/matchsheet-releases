# Release Workflow with Separate Public Repository

## Overview

You have two repositories:
- **Private Repo**: Your source code (where you develop)
- **Public Repo**: Releases only (where users download updates)

This keeps your code private while allowing public access to releases for the auto-update feature.

---

## Initial Setup

### Step 1: Create Your Repositories

1. **Private Repository** (e.g., `matchsheet-private`)
   - Contains your source code
   - Only you have access
   - Where you develop and commit

2. **Public Repository** (e.g., `matchsheet-releases`)
   - Contains only releases
   - Public access
   - No source code
   - Only README and releases

### Step 2: Configure Update Service

Update `lib/services/update_service.dart` to point to your **PUBLIC** releases repository:

```dart
static const String githubOwner = 'YOUR_GITHUB_USERNAME';
static const String githubRepo = 'matchsheet-releases';  // ← Your PUBLIC repo
```

Example:
```dart
static const String githubOwner = 'john-doe';
static const String githubRepo = 'matchsheet-releases';
```

### Step 3: Add Release Repository as Remote

In your private repository, add the public repo as a remote:

```bash
# Navigate to your private repo
cd "c:/Users/HP/opt/digital match sheet/new_app/matchsheet"

# Add the public releases repository as a remote
git remote add releases https://github.com/CrocBOSS/matchsheet-releases.git

# Verify remotes
git remote -v
# You should see:
# origin    https://github.com/YOUR_USERNAME/matchsheet-private.git (your private repo)
# releases  https://github.com/YOUR_USERNAME/matchsheet-releases.git (your public repo)
```

---

## Release Workflow

Every time you want to release a new version:

### Step 1: Update Version & Build APK (Private Repo)

```bash
# 1. Update version in pubspec.yaml
# Change: version: 1.0.0+1
# To:     version: 1.0.1+2

# 2. Build the release APK
flutter build apk --release

# 3. Commit changes to your private repo
git add .
git commit -m "Release v1.0.1: Added speed training feature"
git push origin main
```

### Step 2: Create Tag & Push to Public Releases Repo

```bash
# 4. Create a git tag
git tag -a v1.0.1 -m "Release v1.0.1"

# 5. Push ONLY the tag to the public releases repository
git push releases v1.0.1

# NOTE: This only pushes the tag, NOT your source code!
```

### Step 3: Create GitHub Release

1. Go to your **PUBLIC** repository: `https://github.com/YOUR_USERNAME/matchsheet-releases/releases`
2. Click "Create a new release"
3. Select tag: `v1.0.1`
4. Title: `Version 1.0.1`
5. Description: Write what's new (release notes)
6. **Upload APK**: Drag `build/app/outputs/flutter-apk/app-release.apk`
7. Click "Publish release"

---

## Complete Commands Reference

```bash
# In your private repository directory
cd "c:/Users/HP/opt/digital match sheet/new_app/matchsheet"

# Update version in pubspec.yaml first!

# Build APK
flutter build apk --release

# Commit to private repo
git add .
git commit -m "Release v1.0.0: Description of changes"
git push origin main

# Create and push tag to public releases repo
git tag -a v1.0.0 -m "Release v1.0.1"
git push releases v1.0.0

# Then go to GitHub and create the release with APK upload
```

---

## One-Time Setup Script

Save this as `setup-releases-remote.bat` in your project root:

```batch
@echo off
echo Setting up releases repository remote...

REM Replace with your actual GitHub username and repos
set GITHUB_USERNAME=YOUR_GITHUB_USERNAME
set RELEASES_REPO=matchsheet-releases

echo.
echo Adding releases remote...
git remote add releases https://github.com/%GITHUB_USERNAME%/%RELEASES_REPO%.git

echo.
echo Verifying remotes...
git remote -v

echo.
echo Done! Your remotes are configured.
echo.
echo Private repo (origin): For your source code
echo Public repo (releases): For tags and releases only
pause
```

Run it once: `setup-releases-remote.bat`

---

## Release Script

Save this as `create-release.bat` to automate the release process:

```batch
@echo off
echo ========================================
echo Match Sheet - Create Release
echo ========================================
echo.

REM Check if version is provided
if "%1"=="" (
    echo Usage: create-release.bat VERSION
    echo Example: create-release.bat 1.0.1
    exit /b 1
)

set VERSION=%1
set TAG_NAME=v%VERSION%

echo Creating release for version %VERSION%
echo.

REM Step 1: Build APK
echo [1/4] Building release APK...
flutter build apk --release
if errorlevel 1 (
    echo ERROR: Failed to build APK
    exit /b 1
)
echo.

REM Step 2: Commit changes
echo [2/4] Committing changes to private repo...
git add .
git commit -m "Release %TAG_NAME%"
git push origin main
if errorlevel 1 (
    echo ERROR: Failed to push to origin
    exit /b 1
)
echo.

REM Step 3: Create and push tag
echo [3/4] Creating and pushing tag to releases repo...
git tag -a %TAG_NAME% -m "Release %TAG_NAME%"
git push releases %TAG_NAME%
if errorlevel 1 (
    echo ERROR: Failed to push tag to releases repo
    exit /b 1
)
echo.

REM Step 4: Show next steps
echo [4/4] Tag pushed successfully!
echo.
echo ========================================
echo NEXT STEPS:
echo ========================================
echo 1. Go to: https://github.com/YOUR_USERNAME/matchsheet-releases/releases/new
echo 2. Select tag: %TAG_NAME%
echo 3. Upload APK from: build\app\outputs\flutter-apk\app-release.apk
echo 4. Write release notes
echo 5. Click "Publish release"
echo.
echo APK Location: %cd%\build\app\outputs\flutter-apk\app-release.apk
echo.

REM Open the releases folder
explorer build\app\outputs\flutter-apk

pause
```

Usage:
```batch
# Make sure version in pubspec.yaml is updated first!
create-release.bat 1.0.1
```

---

## Advanced: PowerShell Release Script

Save this as `create-release.ps1` for a more robust solution:

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Message = "Release v$Version"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Match Sheet - Create Release v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Step 1: Build APK
    Write-Host "[1/5] Building release APK..." -ForegroundColor Yellow
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { throw "Failed to build APK" }
    Write-Host "✓ APK built successfully" -ForegroundColor Green
    Write-Host ""
    
    # Step 2: Verify APK exists
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    if (-not (Test-Path $apkPath)) {
        throw "APK not found at $apkPath"
    }
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "  APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Gray
    Write-Host ""
    
    # Step 3: Commit to private repo
    Write-Host "[2/5] Committing to private repo..." -ForegroundColor Yellow
    git add .
    git commit -m $Message
    git push origin main
    if ($LASTEXITCODE -ne 0) { throw "Failed to push to origin" }
    Write-Host "✓ Pushed to private repo" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Create and push tag
    Write-Host "[3/5] Creating tag v$Version..." -ForegroundColor Yellow
    git tag -a "v$Version" -m $Message
    if ($LASTEXITCODE -ne 0) { throw "Failed to create tag" }
    Write-Host "✓ Tag created" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[4/5] Pushing tag to releases repo..." -ForegroundColor Yellow
    git push releases "v$Version"
    if ($LASTEXITCODE -ne 0) { throw "Failed to push tag to releases repo" }
    Write-Host "✓ Tag pushed to releases repo" -ForegroundColor Green
    Write-Host ""
    
    # Step 5: Show next steps
    Write-Host "[5/5] Opening GitHub releases page..." -ForegroundColor Yellow
    $username = git config user.name
    $releasesUrl = "https://github.com/$username/matchsheet-releases/releases/new?tag=v$Version"
    Start-Process $releasesUrl
    Write-Host "✓ Opened in browser" -ForegroundColor Green
    Write-Host ""
    
    # Open APK location
    explorer "build\app\outputs\flutter-apk"
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SUCCESS! Tag v$Version created" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Upload APK from the opened folder" -ForegroundColor White
    Write-Host "2. Write release notes in the browser" -ForegroundColor White
    Write-Host "3. Click 'Publish release'" -ForegroundColor White
    Write-Host ""
    Write-Host "APK: $apkPath" -ForegroundColor Gray
    
} catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
```

Usage:
```powershell
# Basic usage
.\create-release.ps1 -Version 1.0.1

# With custom message
.\create-release.ps1 -Version 1.0.1 -Message "Release v1.0.1: Added speed training"
```

---

## Managing Tags

### List all tags
```bash
git tag
```

### Delete a local tag
```bash
git tag -d v1.0.1
```

### Delete a remote tag (if you made a mistake)
```bash
# From releases repo
git push releases --delete v1.0.1
```

### Push all tags at once (NOT recommended for separate repos)
```bash
# Only if you want to push all tags to releases
git push releases --tags
```

---

## Best Practices

1. **Always update `pubspec.yaml` version BEFORE building**
2. **Test the APK before releasing** (install on device and test)
3. **Write clear release notes** in GitHub release
4. **Keep version tags in sync** with pubspec.yaml
5. **Never push source code to releases repo** (only tags)

---

## Troubleshooting

### "Remote 'releases' not found"
```bash
# Check your remotes
git remote -v

# Add it again
git remote add releases https://github.com/YOUR_USERNAME/matchsheet-releases.git
```

### "Tag already exists"
```bash
# Delete the local tag
git tag -d v1.0.1

# Delete the remote tag (if already pushed)
git push releases --delete v1.0.1

# Create it again
git tag -a v1.0.1 -m "Release v1.0.1"
git push releases v1.0.1
```

### "Permission denied" when pushing tag
- Make sure you have write access to the public releases repository
- Check your GitHub authentication (token or SSH key)

---

## Summary

**Your Workflow:**
1. Develop in **private repo** → `git push origin main`
2. When ready to release → Build APK
3. Create tag → `git tag -a v1.0.1 -m "Release v1.0.1"`
4. Push tag to **public releases repo** → `git push releases v1.0.1`
5. Create GitHub release on public repo with APK
6. Users get auto-updates from public repo!

**Result:** Your source code stays private, but users can download and auto-update from your public releases repository.
