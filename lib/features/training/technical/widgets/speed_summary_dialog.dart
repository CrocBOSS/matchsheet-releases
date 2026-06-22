import 'package:flutter/material.dart';
import '../models/speed_attempt.dart';

/// Shows a summary dialog with speed training session statistics
/// 
/// Displays total attempts, best time, average time, success rate,
/// and a list of all recorded times.
/// 
/// Returns true if user wants to record another attempt,
/// Returns false if user is done (will save and exit)
Future<bool?> showSpeedSummaryDialog({
  required BuildContext context,
  required List<SpeedAttempt> attempts,
  required int targetInMilliseconds,
  required String targetTimeUnit,
  required String distanceUnit,
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _SpeedSummaryDialog(
      attempts: attempts,
      targetInMilliseconds: targetInMilliseconds,
      targetTimeUnit: targetTimeUnit,
      distanceUnit: distanceUnit,
    ),
  );
}

class _SpeedSummaryDialog extends StatelessWidget {
  final List<SpeedAttempt> attempts;
  final int targetInMilliseconds;
  final String targetTimeUnit;
  final String distanceUnit;

  const _SpeedSummaryDialog({
    required this.attempts,
    required this.targetInMilliseconds,
    required this.targetTimeUnit,
    required this.distanceUnit,
  });

  int get _bestTime {
    if (attempts.isEmpty) return 0;
    return attempts.map((a) => a.timeInMilliseconds).reduce((a, b) => a < b ? a : b);
  }

  double get _averageTime {
    if (attempts.isEmpty) return 0;
    final sum = attempts.fold<int>(0, (sum, a) => sum + a.timeInMilliseconds);
    return sum / attempts.length;
  }

  double get _successRate {
    if (attempts.isEmpty) return 0;
    final successCount = attempts.where((a) => a.metTarget).length;
    return (successCount / attempts.length) * 100;
  }

  String _formatTime(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (milliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.celebration,
            color: Colors.amber.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Speed Training Complete!'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatCard(
                context,
                'Total Attempts',
                '${attempts.length}',
                Icons.format_list_numbered,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              
              _buildStatCard(
                context,
                'Best Time',
                _formatTime(_bestTime),
                Icons.emoji_events,
                Colors.amber,
              ),
              const SizedBox(height: 12),
              
              _buildStatCard(
                context,
                'Average Time',
                _formatTime(_averageTime.round()),
                Icons.timeline,
                Colors.purple,
              ),
              const SizedBox(height: 12),
              
              _buildStatCard(
                context,
                'Success Rate',
                '${_successRate.toStringAsFixed(0)}% (${attempts.where((a) => a.metTarget).length}/${attempts.length})',
                Icons.check_circle,
                Colors.green,
              ),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              
              // All Times Section
              Text(
                'All Times:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              
              // List of all attempts
              ...attempts.map((attempt) => _buildAttemptRow(context, attempt)).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, size: 18),
              const SizedBox(width: 8),
              const Text('Record Another Attempt'),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 18),
              SizedBox(width: 8),
              Text('Done'),
            ],
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptRow(BuildContext context, SpeedAttempt attempt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Attempt number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: attempt.metTarget ? Colors.green : Colors.orange,
            ),
            child: Center(
              child: Text(
                '${attempt.attemptNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Time
          Expanded(
            child: Text(
              attempt.formattedTime,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          
          // Success/failure icon
          Icon(
            attempt.metTarget ? Icons.check_circle : Icons.cancel,
            color: attempt.metTarget ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          
          // Difference
          Text(
            attempt.getDifferenceFromTarget(targetInMilliseconds),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: attempt.metTarget ? Colors.green.shade700 : Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
