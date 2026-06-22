# Setup script for adding releases repository as a remote

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Match Sheet - Setup Releases Remote" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get GitHub username
Write-Host "Enter your GitHub username:" -ForegroundColor Yellow
$username = Read-Host

# Get releases repository name
Write-Host ""
Write-Host "Enter your releases repository name:" -ForegroundColor Yellow
Write-Host "(e.g., matchsheet-releases)" -ForegroundColor Gray
$repoName = Read-Host

if (-not $username -or -not $repoName) {
    Write-Host ""
    Write-Host "ERROR: Username and repository name are required" -ForegroundColor Red
    exit 1
}

# Construct URL
$repoUrl = "https://github.com/$username/$repoName.git"

Write-Host ""
Write-Host "Repository URL: $repoUrl" -ForegroundColor Gray
Write-Host ""

# Check if remote already exists
$existingRemote = git remote | Where-Object { $_ -eq "releases" }

if ($existingRemote) {
    Write-Host "⚠ Remote 'releases' already exists" -ForegroundColor Yellow
    Write-Host ""
    git remote get-url releases
    Write-Host ""
    $overwrite = Read-Host "Replace it? (y/n)"
    
    if ($overwrite -eq "y") {
        git remote remove releases
        Write-Host "✓ Old remote removed" -ForegroundColor Green
    } else {
        Write-Host "Keeping existing remote. Exiting..." -ForegroundColor Yellow
        exit 0
    }
}

# Add the remote
Write-Host ""
Write-Host "Adding releases remote..." -ForegroundColor Yellow
git remote add releases $repoUrl

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Failed to add remote" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Remote added successfully!" -ForegroundColor Green
Write-Host ""

# Verify
Write-Host "Current remotes:" -ForegroundColor Yellow
Write-Host ""
git remote -v
Write-Host ""

# Update update_service.dart
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IMPORTANT: Update Configuration" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now update lib/services/update_service.dart:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  static const String githubOwner = '$username';" -ForegroundColor White
Write-Host "  static const String githubRepo = '$repoName';" -ForegroundColor White
Write-Host ""

# Save config to a file for reference
$configText = @"
GitHub Configuration
====================
Username: $username
Releases Repo: $repoName
URL: $repoUrl

Update lib/services/update_service.dart with:
  static const String githubOwner = '$username';
  static const String githubRepo = '$repoName';
"@

$configText | Out-File -FilePath "github-config.txt" -Encoding UTF8
Write-Host "Configuration saved to: github-config.txt" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update lib/services/update_service.dart (see above)" -ForegroundColor White
Write-Host "2. Create a release: .\create-release.ps1 -Version 1.0.0" -ForegroundColor White
Write-Host ""
