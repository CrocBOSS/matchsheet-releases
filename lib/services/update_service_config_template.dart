/// ⚠️ CONFIGURATION REQUIRED ⚠️
/// 
/// Before using the auto-update feature, you MUST update the following constants
/// in lib/services/update_service.dart:
///
/// 1. Replace 'YOUR_GITHUB_USERNAME' with your actual GitHub username
///    Example: 'john-doe' or 'acme-corp'
///
/// 2. Replace 'YOUR_REPO_NAME' with your repository name
///    Example: 'matchsheet-app' or 'my-flutter-app'
///
/// Example configuration:
/// ```dart
/// static const String githubOwner = 'john-doe';
/// static const String githubRepo = 'matchsheet-app';
/// ```
///
/// This will check for updates at:
/// https://api.github.com/repos/john-doe/matchsheet-app/releases/latest
///
/// IMPORTANT: Your repository must be public, OR you need to handle authentication
/// for private repositories.
///
/// See QUICK_START.md for complete setup instructions.

class UpdateServiceConfigTemplate {
  // This is just a template/documentation file
  // The actual configuration is in lib/services/update_service.dart
}
