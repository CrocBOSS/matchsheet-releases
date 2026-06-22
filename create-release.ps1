param(
    [Parameter(Mandatory=$true, HelpMessage="Version number (e.g., 1.0.1)")]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Message = "Release v$Version"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Match Sheet - Create Release v$Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Verify we're in the correct directory
    if (-not (Test-Path "pubspec.yaml")) {
        throw "pubspec.yaml not found. Please run this script from the project root."
    }
    
    # Check version in pubspec.yaml
    Write-Host "[0/5] Checking version in pubspec.yaml..." -ForegroundColor Yellow
    $pubspecContent = Get-Content "pubspec.yaml" -Raw
    if ($pubspecContent -match "version:\s*$Version\+\d+") {
        Write-Host "✓ Version $Version found in pubspec.yaml" -ForegroundColor Green
    } else {
        Write-Host "⚠ Warning: Version $Version not found in pubspec.yaml" -ForegroundColor Red
        Write-Host "  Please update pubspec.yaml first!" -ForegroundColor Red
        $continue = Read-Host "Continue anyway? (y/n)"
        if ($continue -ne "y") {
            exit 1
        }
    }
    Write-Host ""
    
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
    Write-Host "  APK Location: $apkPath" -ForegroundColor Gray
    Write-Host "  APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Gray
    Write-Host ""
    
    # Step 3: Commit to private repo
    Write-Host "[2/5] Committing to private repo..." -ForegroundColor Yellow
    git add .
    git commit -m $Message
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ℹ No changes to commit (or commit failed)" -ForegroundColor Yellow
    } else {
        Write-Host "✓ Changes committed" -ForegroundColor Green
    }
    
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠ Warning: Failed to push to origin" -ForegroundColor Yellow
        Write-Host "  Continuing with tag creation..." -ForegroundColor Yellow
    } else {
        Write-Host "✓ Pushed to private repo" -ForegroundColor Green
    }
    Write-Host ""
    
    # Step 4: Create tag
    Write-Host "[3/5] Creating tag v$Version..." -ForegroundColor Yellow
    
    # Check if tag already exists
    $tagExists = git tag -l "v$Version"
    if ($tagExists) {
        Write-Host "⚠ Tag v$Version already exists locally" -ForegroundColor Yellow
        $overwrite = Read-Host "Delete and recreate? (y/n)"
        if ($overwrite -eq "y") {
            git tag -d "v$Version"
            Write-Host "  Deleted old tag" -ForegroundColor Gray
        } else {
            throw "Tag already exists. Aborted."
        }
    }
    
    git tag -a "v$Version" -m $Message
    if ($LASTEXITCODE -ne 0) { throw "Failed to create tag" }
    Write-Host "✓ Tag v$Version created" -ForegroundColor Green
    Write-Host ""
    
    # Step 5: Push tag to releases repo
    Write-Host "[4/5] Pushing tag to releases repo..." -ForegroundColor Yellow
    
    # Check if releases remote exists
    $releasesRemote = git remote | Where-Object { $_ -eq "releases" }
    if (-not $releasesRemote) {
        Write-Host "⚠ Remote 'releases' not found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please add your releases repository as a remote:" -ForegroundColor Yellow
        Write-Host "  git remote add releases https://github.com/YOUR_USERNAME/YOUR_RELEASES_REPO.git" -ForegroundColor White
        Write-Host ""
        throw "Releases remote not configured"
    }
    
    git push releases "v$Version"
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "⚠ Failed to push tag to releases repo" -ForegroundColor Red
        Write-Host "  You may need to push manually:" -ForegroundColor Yellow
        Write-Host "  git push releases v$Version" -ForegroundColor White
        Write-Host ""
        $continue = Read-Host "Continue anyway? (y/n)"
        if ($continue -ne "y") {
            exit 1
        }
    } else {
        Write-Host "✓ Tag pushed to releases repo" -ForegroundColor Green
    }
    Write-Host ""
    
    # Step 6: Open GitHub and APK location
    Write-Host "[5/5] Opening release locations..." -ForegroundColor Yellow
    
    # Try to get GitHub username from git config
    $gitUser = git config user.name
    $releasesRepoUrl = git remote get-url releases 2>$null
    
    if ($releasesRepoUrl) {
        # Extract repo info from URL
        if ($releasesRepoUrl -match "github\.com[:/](.+)/(.+)\.git") {
            $owner = $matches[1]
            $repo = $matches[2]
            $releasesUrl = "https://github.com/$owner/$repo/releases/new?tag=v$Version"
            Start-Process $releasesUrl
            Write-Host "✓ Opened GitHub releases page in browser" -ForegroundColor Green
        }
    } else {
        Write-Host "ℹ Could not auto-open GitHub. Open manually:" -ForegroundColor Yellow
        Write-Host "  https://github.com/YOUR_USERNAME/YOUR_RELEASES_REPO/releases/new?tag=v$Version" -ForegroundColor White
    }
    
    # Open APK location
    Start-Process "explorer" -ArgumentList "build\app\outputs\flutter-apk"
    Write-Host "✓ Opened APK folder" -ForegroundColor Green
    Write-Host ""
    
    # Success summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✓ SUCCESS! Release v$Version created" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "1. Upload app-release.apk from the opened folder" -ForegroundColor White
    Write-Host "2. Write release notes on GitHub" -ForegroundColor White
    Write-Host "3. Click 'Publish release'" -ForegroundColor White
    Write-Host ""
    Write-Host "APK: $apkPath ($([math]::Round($apkSize, 2)) MB)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "• Update version in pubspec.yaml" -ForegroundColor White
    Write-Host "• Add releases remote: git remote add releases URL" -ForegroundColor White
    Write-Host "• Check git credentials" -ForegroundColor White
    Write-Host ""
    exit 1
}
