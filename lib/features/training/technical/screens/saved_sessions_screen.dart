import 'package:flutter/material.dart';
import '../../models/training_player.dart';
import '../../../../services/storage_service.dart';

class SavedTechnicalTrainingScreen extends StatefulWidget {
  final TrainingPlayer player;

  const SavedTechnicalTrainingScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SavedTechnicalTrainingScreen> createState() => _SavedTechnicalTrainingScreenState();
}

class _SavedTechnicalTrainingScreenState extends State<SavedTechnicalTrainingScreen> {
  late Future<List<Map<String, dynamic>>> _savedSessionsFuture;
  late Future<List<Map<String, dynamic>>> _speedSessionsFuture;

  @override
  void initState() {
    super.initState();
    _savedSessionsFuture = StorageService.loadSavedTechnicalTrainingSessions(
      playerId: widget.player.id,
    );
    _speedSessionsFuture = StorageService.loadSpeedTrainingSessions(
      playerId: widget.player.id,
    );
  }

  Future<void> _deleteSession(int index, bool isSpeedSession, String sessionId) async {
    if (isSpeedSession) {
      await StorageService.deleteSpeedTrainingSession(sessionId);
    } else {
      await StorageService.deleteTechnicalTrainingSession(
        index,
        playerId: widget.player.id,
      );
    }
    setState(() {
      _savedSessionsFuture = StorageService.loadSavedTechnicalTrainingSessions(
        playerId: widget.player.id,
      );
      _speedSessionsFuture = StorageService.loadSpeedTrainingSessions(
        playerId: widget.player.id,
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Training session deleted'),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  String _formatDateTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }

  String _formatTime(int milliseconds) {
    final minutes = (milliseconds ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((milliseconds % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (milliseconds % 1000).toString().padLeft(3, '0');
    return '$minutes:$seconds.$millis';
  }

  Widget _buildTechnicalSessionCard(BuildContext context, Map<String, dynamic> session, int index) {
    final sessionName = session['name'] as String? ?? 'Unknown';
    final skillLabel = session['skillLabel'] as String? ?? 'Unknown Skill';
    final timestamp = session['timestamp'] as String? ?? '';
    final score = session['currentScore'] as num? ?? 0;
    final formattedTime = _formatDateTime(timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showTechnicalSessionDetails(context, sessionName, skillLabel, formattedTime, session);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skillLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${score.toStringAsFixed(1)}/10',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Session'),
                          content: Text(
                            'Are you sure you want to delete "$sessionName"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteSession(index, false, '');
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSessionCard(BuildContext context, Map<String, dynamic> session, int index) {
    final date = session['date'] as String? ?? '';
    final bestTime = session['bestTime'] as int? ?? 0;
    final sessionId = session['sessionId'] as String? ?? '';
    
    final formattedTime = _formatDateTime(date);
    final formattedBestTime = _formatTime(bestTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showSpeedSessionDetails(context, session);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Speed Training',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          formattedBestTime,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                                fontFamily: 'monospace',
                              ),
                        ),
                        Text(
                          'Best',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.amber.shade700,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Session'),
                          content: const Text(
                            'Are you sure you want to delete this speed training session?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteSession(index, true, sessionId);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTechnicalSessionDetails(
    BuildContext context,
    String sessionName,
    String skillLabel,
    String timestamp,
    Map<String, dynamic> session,
  ) {
    final successful = session['successful'] as int? ?? 0;
    final neutral = session['neutral'] as int? ?? 0;
    final fail = session['fail'] as int? ?? 0;
    final score = session['currentScore'] as num? ?? 0;
    final targetScore = session['targetScore'] as num?;
    final totalReps = session['totalReps'] as int?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sessionName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skill: $skillLabel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved: $timestamp',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Final Score',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${score.toStringAsFixed(1)}/10',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Attempt Breakdown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '✓ Successful: $successful',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '⊙ Neutral: $neutral',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '✗ Failed: $fail',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              if (targetScore != null || totalReps != null) ...[
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Target Configuration',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                if (targetScore != null)
                  Text(
                    'Target Score: ${targetScore.toStringAsFixed(1)}/10',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (totalReps != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Total Reps: $totalReps',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSpeedSessionDetails(BuildContext context, Map<String, dynamic> session) {
    final playerName = session['playerName'] as String? ?? 'Unknown';
    final date = session['date'] as String? ?? '';
    final targetTime = session['targetTime'] as double? ?? 0.0;
    final targetTimeUnit = session['targetTimeUnit'] as String? ?? 'seconds';
    final distance = session['distance'] as double? ?? 0.0;
    final distanceUnit = session['distanceUnit'] as String? ?? 'meters';
    final bestTime = session['bestTime'] as int? ?? 0;
    final averageTime = session['averageTime'] as double? ?? 0.0;
    final successRate = session['successRate'] as double? ?? 0.0;
    final attempts = session['attempts'] as List? ?? [];
    
    final formattedDate = _formatDateTime(date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.speed, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(playerName)),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved: $formattedDate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Configuration
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text('Target: $targetTime $targetTimeUnit'),
                      Text('Distance: $distance $distanceUnit'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Statistics
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text('Total Attempts: ${attempts.length}'),
                Text('Best Time: ${_formatTime(bestTime)}'),
                Text('Average Time: ${_formatTime(averageTime.round())}'),
                Text('Success Rate: ${successRate.toStringAsFixed(0)}%'),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Attempts list
                Text(
                  'All Attempts:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...attempts.map((attempt) {
                  final attemptNumber = attempt['attemptNumber'] as int? ?? 0;
                  final timeInMs = attempt['timeInMilliseconds'] as int? ?? 0;
                  final metTarget = attempt['metTarget'] as bool? ?? false;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          metTarget ? Icons.check_circle : Icons.cancel,
                          color: metTarget ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text('#$attemptNumber: ${_formatTime(timeInMs)}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.player.name} - Saved Sessions'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: Future.wait([_savedSessionsFuture, _speedSessionsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final technicalSessions = snapshot.data?[0] ?? [];
          final speedSessions = snapshot.data?[1] ?? [];
          
          // Combine both session types
          final allSessions = <Map<String, dynamic>>[];
          
          // Add technical sessions with type marker
          for (var session in technicalSessions) {
            allSessions.add({...session, '_isSpeedSession': false});
          }
          
          // Add speed sessions with type marker
          for (var session in speedSessions) {
            allSessions.add({...session, '_isSpeedSession': true});
          }
          
          // Sort by date (newest first)
          allSessions.sort((a, b) {
            final aDate = DateTime.tryParse(a['date'] as String? ?? a['timestamp'] as String? ?? '');
            final bDate = DateTime.tryParse(b['date'] as String? ?? b['timestamp'] as String? ?? '');
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });

          if (allSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved training sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: allSessions.length,
            itemBuilder: (context, index) {
              final session = allSessions[index];
              final isSpeedSession = session['_isSpeedSession'] as bool? ?? false;
              
              if (isSpeedSession) {
                return _buildSpeedSessionCard(context, session, index);
              } else {
                return _buildTechnicalSessionCard(context, session, index);
              }
            },
          );
        },
      ),
    );
  }
}

