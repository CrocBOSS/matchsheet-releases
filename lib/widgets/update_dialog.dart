import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

/// Dialog to display when an update is available
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({
    Key? key,
    required this.updateInfo,
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Update Available'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Version',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.updateInfo.currentVersion,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'New Version',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.updateInfo.latestVersion,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Release notes
            if (widget.updateInfo.releaseNotes.isNotEmpty) ...[
              Text(
                'What\'s New:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateInfo.releaseNotes,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Download progress
            if (_isDownloading) ...[
              Column(
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Download warning
            if (!_isDownloading && widget.updateInfo.hasDownloadUrl)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The app will download the update. You\'ll need to install it manually.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: _isDownloading
          ? null
          : [
              // Skip this version
              TextButton(
                onPressed: () async {
                  await UpdateService.skipVersion(widget.updateInfo.latestVersion);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Skip This Version'),
              ),

              // Remind later
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),

              // Download/Update button
              if (widget.updateInfo.hasDownloadUrl)
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download Update'),
                  onPressed: _downloadUpdate,
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Release'),
                  onPressed: () => _openGitHubRelease(),
                ),
            ],
    );
  }

  Future<void> _downloadUpdate() async {
    if (!widget.updateInfo.hasDownloadUrl) return;

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      final success = await UpdateService.downloadAndInstallUpdate(
        widget.updateInfo.downloadUrl!,
        (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      if (success) {
        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Download Complete'),
              content: const Text(
                'The update has been downloaded successfully. Please install it to complete the update.\n\n'
                'You may need to enable "Install from Unknown Sources" in your device settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context); // Close update dialog
                  },
                  child: const Text('OK'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.install_mobile),
                  label: const Text('Install Now'),
                  onPressed: () => _installApk(),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to download update. Please try again.';
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isDownloading = false;
      });
    }
  }

  Future<void> _installApk() async {
    try {
      final apkPath = await UpdateService.getDownloadedApkPath();
      if (apkPath != null) {
        final uri = Uri.file(apkPath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open the installer. Please install the APK manually from Downloads folder.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openGitHubRelease() async {
    final url = Uri.parse('https://github.com/${UpdateService.githubOwner}/${UpdateService.githubRepo}/releases/latest');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
