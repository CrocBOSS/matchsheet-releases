import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/training_player.dart';
import '../models/speed_attempt.dart';
import '../widgets/speed_summary_dialog.dart';
import '../../../../services/storage_service.dart';

class SpeedTrainingScreen extends StatefulWidget {
  final double targetTime;
  final String targetTimeUnit;
  final double distance;
  final String distanceUnit;
  final TrainingPlayer player;

  const SpeedTrainingScreen({
    Key? key,
    required this.targetTime,
    required this.targetTimeUnit,
    required this.distance,
    required this.distanceUnit,
    required this.player,
  }) : super(key: key);

  @override
  State<SpeedTrainingScreen> createState() => _SpeedTrainingScreenState();
}

class _SpeedTrainingScreenState extends State<SpeedTrainingScreen> {
  // Timer components
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _elapsedMilliseconds = 0;

  // Attempt tracking
  final List<SpeedAttempt> _attempts = [];
  int _currentAttemptNumber = 1;
  late int _targetInMilliseconds;

  // State
  bool get _isRunning => _stopwatch.isRunning;
  bool get _canReset => !_isRunning && _elapsedMilliseconds > 0;
  bool get _canRecordTime => _elapsedMilliseconds > 0;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _targetInMilliseconds = _convertToMilliseconds(widget.targetTime, widget.targetTimeUnit);
  }

  @override
  void dispose() {
    _stopTimer();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _stopwatch.start();
    });

    // Update UI every 10ms for smooth milliseconds display
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (mounted) {
        setState(() {
          _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
        });
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _stopwatch.stop();
      _timer?.cancel();
      _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
    });
  }

  void _resetTimer() {
    if (!_isRunning) {
      setState(() {
        _stopwatch.reset();
        _elapsedMilliseconds = 0;
      });
    }
  }

  String _formatTime(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (milliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }

  int _convertToMilliseconds(double time, String unit) {
    if (unit == 'minutes') {
      return (time * 60 * 1000).round();
    }
    return (time * 1000).round();
  }

  void _recordTime() {
    if (_elapsedMilliseconds == 0) return;

    // Calculate if attempt met target
    final metTarget = _elapsedMilliseconds <= _targetInMilliseconds;

    // Create SpeedAttempt instance
    final attempt = SpeedAttempt(
      attemptNumber: _currentAttemptNumber,
      timeInMilliseconds: _elapsedMilliseconds,
      metTarget: metTarget,
      timestamp: DateTime.now(),
    );

    setState(() {
      // Add attempt to list
      _attempts.add(attempt);
      // Increment counter for next attempt
      _currentAttemptNumber++;
    });

    // Auto-reset timer for next attempt
    _resetTimer();

    // Show confirmation SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attempt #${attempt.attemptNumber} recorded: ${attempt.formattedTime} ${metTarget ? '✓' : '✗'}',
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: metTarget ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _completeTraining() async {
    // Check if any attempts have been recorded
    if (_attempts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record at least one attempt before completing'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show summary dialog
    final recordAnother = await showSpeedSummaryDialog(
      context: context,
      attempts: _attempts,
      targetInMilliseconds: _targetInMilliseconds,
      targetTimeUnit: widget.targetTimeUnit,
      distanceUnit: widget.distanceUnit,
    );

    if (recordAnother == true) {
      // User wants to record another attempt - just close the dialog
      // They're already back on the training screen
    } else if (recordAnother == false) {
      // User pressed Done - save session and exit
      await _saveSession();
    }
  }

  Future<void> _saveSession() async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Saving session...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Save the session using StorageService
      await StorageService.saveSpeedTrainingSession(
        playerName: widget.player.name,
        playerId: widget.player.id,
        targetTime: widget.targetTime,
        targetTimeUnit: widget.targetTimeUnit,
        distance: widget.distance,
        distanceUnit: widget.distanceUnit,
        attempts: _attempts.map((a) => a.toJson()).toList(),
      );

      // Dismiss loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('Session saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Wait a moment for user to see the success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate back to skill selection screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Dismiss loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Error saving session: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveSession,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Speed Training'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Complete Training',
            onPressed: _completeTraining,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Target Info Card
                _buildTargetInfoCard(),
                const SizedBox(height: 32),

                // Timer Display
                _buildTimerDisplay(),
                const SizedBox(height: 8),
                
                // Format label
                Center(
                  child: Text(
                    'MM:SS.mmm',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Start/Stop Button
                _buildStartStopButton(),
                const SizedBox(height: 16),

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: _buildResetButton(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRecordTimeButton(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Attempts section
                _attempts.isEmpty
                    ? SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No attempts recorded yet',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Record a time to see it here',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recorded Attempts (${_attempts.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Use ListView.builder with shrinkWrap
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _attempts.length,
                            itemBuilder: (context, index) {
                              // Show most recent first
                              final attempt = _attempts[_attempts.length - 1 - index];
                              return _buildAttemptCard(attempt);
                            },
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'Target',
                '${widget.targetTime} ${widget.targetTimeUnit}',
                Icons.timer,
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
              _buildInfoItem(
                'Distance',
                '${widget.distance} ${widget.distanceUnit}',
                Icons.straighten,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flag,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Attempt #$_currentAttemptNumber',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _formatTime(_elapsedMilliseconds),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStartStopButton() {
    return SizedBox(
      height: 64,
      child: ElevatedButton(
        onPressed: _isRunning ? _stopTimer : _startTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRunning ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRunning ? Icons.stop : Icons.play_arrow,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _isRunning ? 'STOP TIMER' : 'START TIMER',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _canReset ? _resetTimer : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.secondary,
          side: BorderSide(
            color: _canReset
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              size: 20,
              color: _canReset ? null : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              'Reset',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _canReset ? null : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTimeButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _canRecordTime ? _recordTime : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Record Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptCard(SpeedAttempt attempt) {
    final difference = attempt.getDifferenceFromTarget(_targetInMilliseconds);
    final metTarget = attempt.metTarget;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: metTarget
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: metTarget
              ? Colors.green.shade200
              : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Attempt number badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: metTarget ? Colors.green : Colors.orange,
            ),
            child: Center(
              child: Text(
                '#${attempt.attemptNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Time and difference
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.formattedTime,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: metTarget ? Colors.green.shade900 : Colors.orange.shade900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  difference,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: metTarget ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          
          // Success/failure icon
          Icon(
            metTarget ? Icons.check_circle : Icons.cancel,
            color: metTarget ? Colors.green : Colors.orange,
            size: 32,
          ),
        ],
      ),
    );
  }
}
