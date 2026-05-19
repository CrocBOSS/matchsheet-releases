import 'package:flutter/material.dart';
import '../../../models/training_entry.dart';
import '../../../models/training_player.dart';
import '../../../services/storage_service.dart';

class SavedTrainingScreen extends StatefulWidget {
  final TrainingPlayer player;

  const SavedTrainingScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<SavedTrainingScreen> createState() => _SavedTrainingScreenState();
}

class _SavedTrainingScreenState extends State<SavedTrainingScreen> {
  late Future<List<Map<String, dynamic>>> _savedSessionsFuture;

  @override
  void initState() {
    super.initState();
    _savedSessionsFuture = StorageService.loadSavedStrengthTrainingSessions(
      playerId: widget.player.id,
    );
  }

  Future<void> _deleteSession(int index) async {
    await StorageService.deleteStrengthTrainingSession(
      index,
      playerId: widget.player.id,
    );
    setState(() {
      _savedSessionsFuture = StorageService.loadSavedStrengthTrainingSessions(
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

  /// Get the unit for a given exercise key
  String _getExerciseUnit(String exerciseKey) {
    switch (exerciseKey) {
      case 'crabWalk':
        return 'meters';
      case 'calfRises':
        return 'reps';
      case 'sitUps':
        return 'reps';
      case 'pushUps':
        return 'reps';
      default:
        return 'reps';
    }
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedSessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
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
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final sessionName = session['name'] as String? ?? 'Unknown';
              final timestamp = session['timestamp'] as String? ?? '';
              final entries = (session['entries'] as List<dynamic>?)
                  ?.map((e) => TrainingEntry.fromJson(e as Map<String, dynamic>))
                  .toList() ?? [];

              final formattedTime = _formatDateTime(timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    _showSessionDetails(context, sessionName, formattedTime, entries);
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
                                formattedTime,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        ),
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
                                      _deleteSession(index);
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSessionDetails(
    BuildContext context,
    String sessionName,
    String timestamp,
    List<TrainingEntry> entries,
  ) {
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
                'Saved: $timestamp',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...entries.expand((entry) {
                final widgets = <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      '#${entry.playerNumber} - ${entry.playerName}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ];

                // Group stats by exercise (handle per-leg variants)
                // Note: Left leg uses exerciseKey_left_setN, Right leg uses exerciseKey_setN (without suffix)
                final exerciseMap = <String, Map<String, List<String>>>{};
                for (final stat in entry.customStats.entries) {
                  final parts = stat.key.split('_set');
                  var statPrefix = parts[0]; // e.g., "calfRises_left" or "pushUps" or "calfRises"
                  var leg = 'main'; // default
                  var exerciseName = statPrefix;
                  
                  // Check if it's a per-leg exercise with _left suffix
                  if (statPrefix.endsWith('_left')) {
                    leg = 'left';
                    exerciseName = statPrefix.replaceAll(RegExp(r'_left$'), '');
                  }
                  // Note: Right leg doesn't have a suffix, so we detect it later when we have context
                  
                  if (!exerciseMap.containsKey(exerciseName)) {
                    exerciseMap[exerciseName] = {};
                  }
                  
                  if (!exerciseMap[exerciseName]!.containsKey(leg)) {
                    exerciseMap[exerciseName]![leg] = [];
                  }
                  exerciseMap[exerciseName]![leg]!.add(stat.key);
                }
                
                // Post-process to separate main stats into 'right' for per-leg exercises
                for (final exercise in exerciseMap.entries) {
                  final exerciseName = exercise.key;
                  final legStats = exercise.value;
                  
                  // If we have 'main' stats AND 'left' stats, the 'main' ones are actually 'right' leg
                  if (legStats.containsKey('main') && legStats.containsKey('left')) {
                    legStats['right'] = legStats.remove('main')!;
                  }
                }

                // Build exercise details
                for (final exercise in exerciseMap.entries) {
                  final exerciseName = exercise.key;
                  final legStats = exercise.value;

                  widgets.add(
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
                      child: Text(
                        exerciseName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );

                  // Check if this is a per-leg exercise
                  final isPerLeg = legStats.containsKey('left') || legStats.containsKey('right');

                  if (isPerLeg) {
                    // Display per-leg exercises (left/right)
                    for (final leg in ['left', 'right']) {
                      final statKeys = legStats[leg];
                      if (statKeys != null && statKeys.isNotEmpty) {
                        statKeys.sort((a, b) {
                          final aSetNum = int.tryParse(a.split('_set').last) ?? 0;
                          final bSetNum = int.tryParse(b.split('_set').last) ?? 0;
                          return aSetNum.compareTo(bSetNum);
                        });

                        final legLabel = leg == 'left' ? 'Left Foot' : 'Right Foot';
                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 2),
                            child: Text(
                              legLabel,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        );

                        for (int i = 0; i < statKeys.length; i++) {
                          final statKey = statKeys[i];
                          final reps = entry.customStats[statKey] ?? 0;
                          final setNum = i + 1;
                          final unit = _getExerciseUnit(exerciseName);
                          widgets.add(
                            Padding(
                              padding: const EdgeInsets.only(left: 28, top: 2),
                              child: Text(
                                'Set $setNum: $reps $unit',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  } else {
                    // Display normal exercises (no leg separation)
                    final statKeys = legStats['main'];
                    if (statKeys != null && statKeys.isNotEmpty) {
                      statKeys.sort((a, b) {
                        final aSetNum = int.tryParse(a.split('_set').last) ?? 0;
                        final bSetNum = int.tryParse(b.split('_set').last) ?? 0;
                        return aSetNum.compareTo(bSetNum);
                      });

                      for (int i = 0; i < statKeys.length; i++) {
                        final statKey = statKeys[i];
                        final reps = entry.customStats[statKey] ?? 0;
                        final setNum = i + 1;
                        final unit = _getExerciseUnit(exerciseName);
                        widgets.add(
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Text(
                              'Set $setNum: $reps $unit',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      }
                    }
                  }
                }

                return widgets;
              }),
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

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}
