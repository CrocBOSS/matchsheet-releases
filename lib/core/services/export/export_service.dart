import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'export_strategy.dart';

/// Main export service that uses strategies to export data
/// 
/// This service handles the export workflow:
/// 1. Export data using the provided strategy
/// 2. Save to temporary file
/// 3. Share the file with the user
class ExportService {
  /// Export data and share it with the user
  /// 
  /// [data] - The data to export (format depends on strategy)
  /// [strategy] - The export strategy to use (TXT, Excel, etc.)
  /// [fileName] - Base name for the exported file (without extension)
  /// [subject] - Optional subject line for sharing
  Future<void> exportAndShare({
    required dynamic data,
    required ExportStrategy strategy,
    required String fileName,
    String? subject,
  }) async {
    try {
      // Export data using strategy
      final bytes = await strategy.export(data);

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/$fileName.${strategy.fileExtension}');
      await file.writeAsBytes(bytes);

      // Share the file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? 'Export',
      );
    } catch (e) {
      throw ExportException('Failed to export: $e');
    }
  }
}

/// Custom exception for export errors
class ExportException implements Exception {
  final String message;

  ExportException(this.message);

  @override
  String toString() => message;
}
