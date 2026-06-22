# Auto-Update Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### Step 1: Configure Your GitHub Repository

1. Open `lib/services/update_service.dart`
2. Find lines 10-11 and update with your info:

```dart
static const String githubOwner = 'YOUR_GITHUB_USERNAME';  // ← Change this
static const String githubRepo = 'YOUR_REPO_NAME';         // ← Change this
```

**Example:**
```dart
static const String githubOwner = 'john-smith';
static const String githubRepo = 'matchsheet-app';
```

### Step 2: Build Your First Release

```bash
# 1. Build the APK
flutter build apk --release

# 2. Create a git tag (match your version in pubspec.yaml)
git tag v1.0.0
git push origin v1.0.0
```

### Step 3: Create GitHub Release

1. Go to `https://github.com/YOUR_USERNAME/YOUR_REPO/releases/new`
2. Select tag: `v1.0.0`
3. Title: `Version 1.0.0`
4. Description: Write what's new
5. **Upload the APK** from: `build/app/outputs/flutter-apk/app-release.apk`
6. Click "Publish release"

### Step 4: Test It!

1. Install the old version on your phone
2. Update `pubspec.yaml` version to `1.0.1+2`
3. Build new APK and create release `v1.0.1`
4. Open the app → You'll see an update notification! 🎉

---

## 📱 How Users Will Experience Updates

1. **Open App** → Sees "Update Available" dialog after 2 seconds
2. **Tap "Download Update"** → Progress bar shows download
3. **Tap "Install Now"** → System installer opens
4. **Done!** → App is updated

---

## ⚙️ Settings Menu

Users can also manually check for updates:
- Tap ⋮ menu (top right)
- Select "Check for Updates"
- If available, download & install

---

## 🔄 Your Release Workflow

Every time you want to release a new version:

```bash
# 1. Update version number in pubspec.yaml
# Change: version: 1.0.0+1
# To:     version: 1.0.1+2

# 2. Build APK
flutter build apk --release

# 3. Commit and tag
git add .
git commit -m "Release v1.0.1: Added speed training feature"
git tag v1.0.1
git push origin main
git push origin v1.0.1

# 4. Create release on GitHub
# - Go to Releases → New Release
# - Select tag v1.0.1
# - Upload build/app/outputs/flutter-apk/app-release.apk
# - Publish
```

---

## 📋 Version Numbering

Format: `MAJOR.MINOR.PATCH+BUILD`

Example: `1.2.3+4`
- **1** = Major version (breaking changes)
- **2** = Minor version (new features)
- **3** = Patch (bug fixes)
- **4** = Build number (always increment)

**When releasing:**
- Bug fix: `1.0.0` → `1.0.1`
- New feature: `1.0.1` → `1.1.0`
- Breaking change: `1.1.0` → `2.0.0`

---

## ✅ Checklist Before First Release

- [ ] Updated `githubOwner` in `update_service.dart`
- [ ] Updated `githubRepo` in `update_service.dart`
- [ ] Repository is public (or you have release permissions)
- [ ] Version number is correct in `pubspec.yaml`
- [ ] Built APK with `flutter build apk --release`
- [ ] Created and pushed git tag
- [ ] Created GitHub release
- [ ] Uploaded APK to the release
- [ ] Tested update on a device

---

## 🎯 That's It!

Your app now has automatic updates! Users will be notified when new versions are available, and they can update with just a few taps.

**Need more details?** See `AUTO_UPDATE_SETUP.md` for advanced configuration and automation with GitHub Actions.
