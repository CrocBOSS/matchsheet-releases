# Auto-Update Feature - Complete Guide

## 📚 Documentation Overview

This app has an automatic update system that checks GitHub releases. Here's your complete documentation:

### Quick Start (Choose One)
1. **QUICK_RELEASE_GUIDE.md** - If you have separate public/private repos ⭐ **START HERE**
2. **QUICK_START.md** - If you have one public repo
3. **AUTO_UPDATE_SETUP.md** - Detailed technical guide
4. **RELEASE_WORKFLOW_SEPARATE_REPO.md** - Full guide for two-repo setup

### Scripts Available
- `setup-releases-remote.ps1` - One-time configuration
- `create-release.ps1` - Automated release process (PowerShell)
- `create-release.bat` - Automated release process (Batch)

---

## 🎯 Recommended Workflow (Separate Repos)

### Step 1: Initial Setup (5 minutes)
```powershell
# Run the setup script
.\setup-releases-remote.ps1
```

It will ask for:
- Your GitHub username
- Your releases repository name

Then update `lib/services/update_service.dart` with the values it provides.

### Step 2: Create Your First Release (5 minutes)
```powershell
# Make sure version in pubspec.yaml is set (e.g., 1.0.0+1)
# Then run:
.\create-release.ps1 -Version 1.0.0
```

Follow the prompts:
1. Upload the APK to GitHub release
2. Write release notes
3. Click "Publish release"

### Step 3: Test Auto-Update
1. Install the APK on your device
2. Update version to 1.0.1+2 in pubspec.yaml
3. Run: `.\create-release.ps1 -Version 1.0.1`
4. Publish the release
5. Open the app → You should see update notification! 🎉

---

## 📦 What You Get

### For Users
- **Automatic update checks** when app starts (every 24 hours)
- **Manual update check** via menu (⋮ → Check for Updates)
- **One-tap download** of new versions
- **Easy installation** with guided prompts

### For You (Developer)
- **Simple workflow** - just run one script
- **Private source code** - keep your code private
- **Public releases** - users can download updates
- **Version tracking** - automatic tagging

---

## 🔄 Your Release Routine

Every time you want to release:

```powershell
# 1. Update version in pubspec.yaml
#    Change: version: 1.0.0+1
#    To:     version: 1.0.1+2

# 2. Run release script
.\create-release.ps1 -Version 1.0.1

# 3. Upload APK and publish (browser opens automatically)

# Done! Users will get notified of the update
```

---

## 🎨 Customization

### Change Update Check Frequency
Edit `lib/services/update_service.dart`:
```dart
// Check at most once every 24 hours (default)
return hoursSinceLastCheck >= 24;

// Change to check more/less frequently:
return hoursSinceLastCheck >= 12;  // Every 12 hours
return hoursSinceLastCheck >= 48;  // Every 2 days
```

### Disable Automatic Checks
Comment out the check in `lib/features/home/screens/home_screen.dart`:
```dart
@override
void initState() {
  super.initState();
  // _checkForUpdates();  // ← Comment this out
}
```

Users can still check manually via menu.

---

## 📊 How It Works

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Your App   │────────▶│ GitHub API   │────────▶│   Public    │
│  (Device)   │  Check  │   Releases   │  Fetch  │  Releases   │
└─────────────┘         └──────────────┘         │    Repo     │
       │                                          └─────────────┘
       │                                                 ▲
       │ Download APK                                   │
       ▼                                                │
┌─────────────┐                               ┌────────┴────────┐
│   Install   │                               │  create-release │
│   Update    │                               │     script      │
└─────────────┘                               └─────────────────┘
                                                      ▲
                                              ┌───────┴────────┐
                                              │  Private Repo  │
                                              │ (Source Code)  │
                                              └────────────────┘
```

1. You develop in private repo
2. Script creates tag and pushes to public releases repo
3. You upload APK to GitHub release
4. App checks GitHub API for new versions
5. Users download and install updates

---

## 🔐 Security & Privacy

- ✅ **Source code stays private** (in your private repo)
- ✅ **Only APKs are public** (in releases repo)
- ✅ **Users verify installation** (manual approval required)
- ✅ **HTTPS downloads** (secure connection)
- ✅ **GitHub hosting** (trusted platform)

---

## 🧪 Testing Checklist

Before releasing to users:
- [ ] Test APK on real device
- [ ] Verify all features work
- [ ] Check APK size (should be reasonable)
- [ ] Test update flow (install old, update to new)
- [ ] Review release notes for clarity
- [ ] Confirm version numbers match everywhere

---

## 📱 User Experience

### First Install
1. User downloads APK from GitHub releases
2. Installs manually
3. Opens app

### Subsequent Updates
1. User opens app
2. Sees "Update Available" dialog (if new version exists)
3. Taps "Download Update"
4. Waits for download (progress bar shown)
5. Taps "Install Now"
6. System installer opens
7. Confirms installation
8. Updated! 🎉

### Manual Update Check
1. Opens app
2. Taps ⋮ menu (top right)
3. Selects "Check for Updates"
4. Follows same flow if update available

---

## 🆘 Getting Help

### Check These Files
1. `QUICK_RELEASE_GUIDE.md` - Quick reference
2. `RELEASE_WORKFLOW_SEPARATE_REPO.md` - Detailed workflow
3. `AUTO_UPDATE_SETUP.md` - Technical details

### Common Issues
See "Troubleshooting" section in `QUICK_RELEASE_GUIDE.md`

### Still Stuck?
1. Check the scripts ran without errors
2. Verify version in pubspec.yaml matches tag
3. Confirm releases repo is public
4. Check APK uploaded to GitHub release
5. Verify update_service.dart has correct repo info

---

## 📝 Quick Reference Card

```
╔════════════════════════════════════════════════════════════╗
║  Match Sheet - Auto-Update Quick Reference                ║
╠════════════════════════════════════════════════════════════╣
║  SETUP (Once)                                             ║
║  .\setup-releases-remote.ps1                              ║
║  → Update lib/services/update_service.dart                ║
╟────────────────────────────────────────────────────────────╢
║  RELEASE (Every time)                                     ║
║  1. Update version in pubspec.yaml                        ║
║  2. .\create-release.ps1 -Version X.Y.Z                   ║
║  3. Upload APK to GitHub                                  ║
║  4. Publish release                                       ║
╟────────────────────────────────────────────────────────────╢
║  FILES TO EDIT                                            ║
║  • pubspec.yaml (version number)                          ║
║  • lib/services/update_service.dart (repo info)          ║
╟────────────────────────────────────────────────────────────╢
║  USEFUL COMMANDS                                          ║
║  git remote -v              (view remotes)                ║
║  git tag                    (list tags)                   ║
║  git tag -d v1.0.1          (delete local tag)           ║
║  git push releases --delete v1.0.1  (delete remote tag)  ║
╚════════════════════════════════════════════════════════════╝
```

---

## 🎉 You're All Set!

You now have a complete auto-update system:
- ✅ Scripts to automate releases
- ✅ Separate repos for code/releases
- ✅ Automatic update notifications
- ✅ Easy installation for users
- ✅ Complete documentation

**Next step:** Run `.\setup-releases-remote.ps1` to get started!
