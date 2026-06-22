import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for checking and downloading app updates from GitHub releases
class UpdateService {
  // TODO: Replace with your GitHub repository details
  static const String githubOwner = 'CrocBOSS';
  static const String githubRepo = 'matchsheet-releases';
  static const String githubApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
  
  static const String _lastCheckKey = 'last_update_check';
  static const String _skipVersionKey = 'skip_version';
  
  /// Check if there's a new version available
  static Future<UpdateInfo?> checkForUpdate({bool forceCheck = false}) async {
    try {
      // Check if we should skip this check based on time
      if (!forceCheck && !await _shouldCheckForUpdate()) {
        return null;
      }
      
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Fetch latest release from GitHub
      final response = await http.get(Uri.parse(githubApiUrl));
      
      if (response.statusCode != 200) {
        debugPrint('Failed to check for updates: ${response.statusCode}');
        return null;
      }
      
      final data = json.decode(response.body);
      final latestVersion = (data['tag_name'] as String).replaceFirst('v', '');
      final releaseNotes = data['body'] as String? ?? '';
      final publishedAt = data['published_at'] as String? ?? '';
      
      // Find APK download URL
      String? downloadUrl;
      final assets = data['assets'] as List?;
      if (assets != null) {
        for (var asset in assets) {
          final name = asset['name'] as String;
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String;
            break;
          }
        }
      }
      
      // Save last check time
      await _saveLastCheckTime();
      
      // Check if skipped
      final skippedVersion = await _getSkippedVersion();
      if (skippedVersion == latestVersion) {
        return null; // User chose to skip this version
      }
      
      // Compare versions
      if (_isNewerVersion(currentVersion, latestVersion)) {
        return UpdateInfo(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
          publishedAt: publishedAt,
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      return null;
    }
  }
  
  /// Download and install the update
  static Future<bool> downloadAndInstallUpdate(
    String downloadUrl,
    Function(double)? onProgress,
  ) async {
    try {
      // Get download directory
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        debugPrint('Could not get storage directory');
        return false;
      }
      
      final filePath = '${dir.path}/app-update.apk';
      
      // Delete old APK if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Download APK
      final dio = Dio();
      await dio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress?.call(progress);
          }
        },
      );
      
      // Install APK (requires permission)
      // Note: On Android 10+, you need to use FileProvider and request INSTALL_PACKAGES permission
      if (Platform.isAndroid) {
        // The APK is downloaded, but installation must be triggered by the user
        // We'll return the file path so the UI can handle installation
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return false;
    }
  }
  
  /// Get the downloaded APK file path
  static Future<String?> getDownloadedApkPath() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return null;
      
      final filePath = '${dir.path}/app-update.apk';
      final file = File(filePath);
      
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting APK path: $e');
      return null;
    }
  }
  
  /// Mark a version as skipped
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skipVersionKey, version);
  }
  
  /// Clear skipped version
  static Future<void> clearSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skipVersionKey);
  }
  
  // Private helper methods
  
  static Future<bool> _shouldCheckForUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey);
    
    if (lastCheck == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSinceLastCheck = (now - lastCheck) / (1000 * 60 * 60);
    
    // Check at most once every 24 hours
    return hoursSinceLastCheck >= 24;
  }
  
  static Future<void> _saveLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<String?> _getSkippedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skipVersionKey);
  }
  
  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      
      if (latestPart > currentPart) return true;
      if (latestPart < currentPart) return false;
    }
    
    return false;
  }
}

/// Model for update information
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String? downloadUrl;
  final String publishedAt;
  
  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    this.downloadUrl,
    required this.publishedAt,
  });
  
  bool get hasDownloadUrl => downloadUrl != null && downloadUrl!.isNotEmpty;
}
