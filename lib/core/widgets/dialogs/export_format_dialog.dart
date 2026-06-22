import 'package:flutter/material.dart';

/// Export format options
enum ExportFormat { txt, excel }

/// Dialog for selecting export format (TXT or Excel)
/// 
/// This reusable dialog allows users to choose between
/// text and Excel export formats.
class ExportFormatDialog extends StatelessWidget {
  const ExportFormatDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Format', style: TextStyle(fontSize: 16)),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select export format:',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.description, color: Colors.blue),
            title: const Text('Text File (.txt)',
                style: TextStyle(fontSize: 13)),
            onTap: () => Navigator.pop(context, ExportFormat.txt),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('Excel File (.xlsx)',
                style: TextStyle(fontSize: 13)),
            onTap: () => Navigator.pop(context, ExportFormat.excel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  /// Show the export format dialog
  /// 
  /// Returns the selected [ExportFormat] or null if cancelled.
  static Future<ExportFormat?> show(BuildContext context) {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => const ExportFormatDialog(),
    );
  }
}
