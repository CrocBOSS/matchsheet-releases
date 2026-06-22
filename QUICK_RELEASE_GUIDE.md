# Quick Release Guide - Two Repository Setup

## 🎯 Your Setup
- **Private Repo**: Your source code (development)
- **Public Repo**: Releases only (for auto-updates)

---

## 🚀 First Time Setup (Do Once)

### Option 1: Use Setup Script (Recommended)
```powershell
.\setup-releases-remote.ps1
```
This will:
- Ask for your GitHub username
- Ask for your releases repository name
- Configure the remote automatically
- Show you what to update in `update_service.dart`

### Option 2: Manual Setup
```bash
# Add releases repo as remote
git remote add releases https://github.com/YOUR_USERNAME/YOUR_RELEASES_REPO.git

# Verify
git remote -v
```

Then update `lib/services/update_service.dart`:
```dart
static const String githubOwner = 'YOUR_USERNAME';
static const String githubRepo = 'YOUR_RELEASES_REPO';
```

---

## 📦 Create a Release (Every Time)

### Option 1: Use Release Script (Easiest)
```powershell
# Update version in pubspec.yaml first!
# Then run:
.\create-release.ps1 -Version 1.0.1
```

This will:
1. ✓ Build the APK
2. ✓ Commit to your private repo
3. ✓ Create and push tag to releases repo
4. ✓ Open GitHub and APK folder
5. → You just upload APK and publish!

### Option 2: Manual Steps
```bash
# 1. Update version in pubspec.yaml

# 2. Build APK
flutter build apk --release

# 3. Commit to private repo
git add .
git commit -m "Release v1.0.1"
git push origin main

# 4. Create and push tag to releases repo
git tag -a v1.0.1 -m "Release v1.0.1"
git push releases v1.0.1

# 5. Go to GitHub, create release, upload APK
```

---

## 📝 Release Checklist

Before running the script:
- [ ] Updated version in `pubspec.yaml`
- [ ] Tested the app
- [ ] Written release notes (what's new)

After running the script:
- [ ] Upload APK to GitHub release
- [ ] Add release notes
- [ ] Click "Publish release"
- [ ] Test auto-update on device

---

## 🔢 Version Numbering

Format: `MAJOR.MINOR.PATCH+BUILD`

Examples:
- Bug fix: `1.0.0+1` → `1.0.1+2`
- New feature: `1.0.1+2` → `1.1.0+3`
- Breaking change: `1.1.0+3` → `2.0.0+4`

**Always increment both version AND build number!**

---

## 🛠️ Common Commands

### View your remotes
```bash
git remote -v
```

### List all tags
```bash
git tag
```

### Delete a tag (if you made a mistake)
```bash
# Delete locally
git tag -d v1.0.1

# Delete from releases repo
git push releases --delete v1.0.1
```

### Check current version
```bash
# In pubspec.yaml
grep version pubspec.yaml
```

---

## 🆘 Troubleshooting

### "Remote 'releases' not found"
Run: `.\setup-releases-remote.ps1`

### "Tag already exists"
```bash
git tag -d v1.0.1  # Delete locally
git push releases --delete v1.0.1  # Delete from releases repo
```
Then create it again.

### "Permission denied" when pushing
- Check you have write access to releases repo
- Update your GitHub token/credentials

### "APK not found"
Make sure the build succeeded:
```bash
flutter build apk --release
```
APK should be at: `build\app\outputs\flutter-apk\app-release.apk`

---

## 📁 File Structure

```
matchsheet/
├── create-release.ps1          ← Main release script
├── setup-releases-remote.ps1   ← One-time setup
├── QUICK_RELEASE_GUIDE.md      ← This file
└── lib/services/update_service.dart  ← Update with your repo info
```

---

## 💡 Tips

1. **Always test before releasing** - Install APK on device first
2. **Write good release notes** - Users want to know what's new
3. **Keep versions incremental** - Don't skip version numbers
4. **Tag names match versions** - v1.0.1 in tag = 1.0.1 in pubspec.yaml
5. **Check APK size** - Try to keep it reasonable (<50MB)

---

## 🎉 Your Workflow Summary

1. **Develop** → Work in private repo
2. **Ready to release** → Update version in `pubspec.yaml`
3. **Run script** → `.\create-release.ps1 -Version 1.0.1`
4. **Upload APK** → To GitHub release (opened automatically)
5. **Publish** → Users get auto-update notification!

That's it! Your source code stays private, users get seamless updates. 🚀
