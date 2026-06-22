# Auto-Update Feature Setup Guide

This app includes an automatic update feature that checks GitHub releases for new versions and allows users to download and install updates without manual intervention.

## How It Works

1. **Automatic Check**: The app checks for updates when it starts (once every 24 hours)
2. **Manual Check**: Users can manually check for updates from the menu (☰ → Check for Updates)
3. **Download**: If an update is available, users can download it directly from the app
4. **Install**: After download, the app prompts users to install the update

## Setup Instructions

### Step 1: Configure GitHub Repository

1. Open `lib/services/update_service.dart`
2. Replace the placeholder values with your GitHub details:

```dart
static const String githubOwner = 'CrocBOSS';  // e.g., 'john-doe'
static const String githubRepo = 'matchsheet-releases';         // e.g., 'match-sheet-app'
```

### Step 2: Create a GitHub Release

When you want to release a new version:

1. **Build the APK**:
   ```bash
   flutter build apk --release
   ```
   The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

2. **Update Version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+1  # Increment the version number
   ```

3. **Create a Git Tag**:
   ```bash
   git add .
   git commit -m "Release version 1.0.1"
   git tag v1.0.1
   git push origin main
   git push origin v1.0.1
   ```

4. **Create GitHub Release**:
   - Go to your GitHub repository
   - Click "Releases" → "Create a new release"
   - Choose the tag you just created (v1.0.1)
   - Set release title: "Version 1.0.1"
   - Add release notes describing what's new:
     ```
     ## What's New in 1.0.1
     
     ### New Features
     - Speed training with timer
     - Export data to Excel/Text
     
     ### Improvements
     - Improved UI performance
     - Better error handling
     
     ### Bug Fixes
     - Fixed crash when saving sessions
     ```
   - **Upload the APK**: Drag and drop `app-release.apk` into the release
   - Click "Publish release"

### Step 3: Test the Auto-Update

1. Install the old version on your device
2. Create and publish a new release on GitHub (as described above)
3. Open the app
4. Wait 2 seconds for the update check (or tap menu → Check for Updates)
5. You should see an update dialog
6. Download and install the update

## Using GitHub Actions (Optional Automation)

You can automate the release process using GitHub Actions. Create `.github/workflows/release.yml`:

```yaml
name: Build and Release APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

With this workflow:
1. Update version in `pubspec.yaml`
2. Commit and push
3. Create and push a tag: `git tag v1.0.1 && git push origin v1.0.1`
4. GitHub Actions will automatically build and create a release with the APK

## Update Flow

### For Developers:

1. Make changes to the code
2. Update version in `pubspec.yaml`
3. Build APK: `flutter build apk --release`
4. Create release on GitHub with the APK
5. Done! Users will be notified

### For Users:

1. Open the app
2. See update notification (automatic)
3. Tap "Download Update"
4. Wait for download to complete
5. Tap "Install Now"
6. Confirm installation
7. Done! App is updated

## Update Frequency

- **Automatic checks**: Once every 24 hours when app starts
- **Manual checks**: Anytime via menu
- **Skip version**: Users can skip a specific version if they want

## Permissions Required

The app needs these Android permissions for auto-update:
- `INTERNET`: To check for updates and download APKs
- `REQUEST_INSTALL_PACKAGES`: To install downloaded APKs
- `WRITE_EXTERNAL_STORAGE`: To save downloaded APKs

## Troubleshooting

### Update not detected
- Verify GitHub repository settings in `update_service.dart`
- Check that the release is published (not draft)
- Ensure the APK is uploaded to the release
- Verify version number in `pubspec.yaml` is higher

### Download fails
- Check internet connection
- Verify the APK file is correctly uploaded to GitHub
- Check storage space on device

### Installation fails
- Enable "Install from unknown sources" in device settings
- Check that the APK was downloaded completely
- Try manual installation from Downloads folder

## Version Comparison

The app uses semantic versioning (X.Y.Z):
- **X** (Major): Breaking changes
- **Y** (Minor): New features
- **Z** (Patch): Bug fixes

Example: `1.2.3` → `1.2.4` (patch update)

## Best Practices

1. **Always test** new versions before releasing
2. **Write clear release notes** so users know what changed
3. **Use semantic versioning** consistently
4. **Test the update flow** with a beta version first
5. **Keep APK size reasonable** (optimize assets, use --split-per-abi if needed)

## Security Notes

- APKs are downloaded from your official GitHub repository only
- Users must explicitly approve the installation
- The app never auto-installs without user consent
- All downloads use HTTPS

## Need Help?

- Check the GitHub Issues page
- Review the update service logs in the app
- Test with manual update check first
- Verify all setup steps were completed correctly
