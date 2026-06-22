import 'package:flutter/material.dart';

/// Reusable dialog helper utilities
/// 
/// Provides common dialog patterns used throughout the app.
class DialogHelpers {
  /// Show a text input dialog for comments/notes
  ///
  /// [context] - BuildContext for showing the dialog
  /// [title] - Dialog title
  /// [initialText] - Initial text in the text field
  /// [labelText] - Label for the text field
  /// [maxLines] - Maximum lines for the text field
  /// [onSave] - Callback function when Save is pressed, receives the text input
  /// [maxWidth] - Optional max width for the dialog (useful for responsive design)
  static Future<void> showTextInputDialog({
    required BuildContext context,
    required String title,
    required String initialText,
    required String labelText,
    required Function(String) onSave,
    int maxLines = 3,
    double? maxWidth,
  }) async {
    final controller = TextEditingController(text: initialText);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 14),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          maxLines: maxLines,
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(fontSize: 12, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  /// Show a rating dialog with numbered options (1-10) and Clear button
  ///
  /// [context] - BuildContext for showing the dialog
  /// [title] - Dialog title
  /// [currentRating] - Current rating value (0-10)
  /// [onRate] - Callback function when a rating is selected, receives the rating value
  static Future<void> showRatingDialog({
    required BuildContext context,
    required String title,
    required int currentRating,
    required Function(int) onRate,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 12)),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(10, (index) {
                  final rating = index + 1;
                  return GestureDetector(
                    onTap: () {
                      onRate(rating);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: currentRating == rating
                            ? Colors.orange
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$rating',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: currentRating == rating
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    onRate(0);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: currentRating == 0
                          ? Colors.orange
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Clear',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            currentRating == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
