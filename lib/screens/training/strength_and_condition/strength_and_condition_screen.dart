import 'package:flutter/material.dart';
import '../../../models/training_entry.dart';
import '../../../models/training_player.dart';
import '../../../services/storage_service.dart';

// Exercise configuration
class ExerciseConfig {
  final String key;
  final String label;
  final int targetReps;
  final int targetSets;
  final bool isPerLeg;
  final String unit; // "reps", "meters", etc.

  ExerciseConfig({
    required this.key,
    required this.label,
    required this.targetReps,
    required this.targetSets,
    required this.isPerLeg,
    this.unit = 'reps',
  });
}

class StrengthAndConditionScreen extends StatefulWidget {
  final ExerciseConfig? selectedExercise;
  final TrainingPlayer player;

  const StrengthAndConditionScreen({
    Key? key,
    this.selectedExercise,
    required this.player,
  }) : super(key: key);

  @override
  State<StrengthAndConditionScreen> createState() => _StrengthAndConditionScreenState();
}

class _StrengthAndConditionScreenState extends State<StrengthAndConditionScreen> {
  List<TrainingEntry> trainingEntries = [];
  int nextEntryId = 1;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadTrainingEntries('strength_condition');
    final allEntries = List<TrainingEntry>.from(data['entries'] as List);
    
    // Filter entries for current player only
    final playerEntries = allEntries.where((e) => e.playerId == widget.player.id).toList();
    
    setState(() {
      trainingEntries = playerEntries;
      nextEntryId = data['nextId'] as int;
      
      // If no entries, add first one automatically
      if (trainingEntries.isEmpty) {
        _addNewEntry();
      }
    });
  }

  void _addNewEntry() {
    final newEntry = TrainingEntry(
      id: nextEntryId,
      playerId: widget.player.id,
      playerNumber: widget.player.number,
      playerName: widget.player.name,
      position: widget.player.position,
      trainingType: 'strength_condition',
    );

    setState(() {
      trainingEntries.add(newEntry);
      nextEntryId++;
      hasUnsavedChanges = true;
    });
    
    _autoSaveData();
  }

  Future<void> _saveData() async {
    // Save to temporary storage first
    await StorageService.saveTrainingEntries(
      trainingEntries,
      nextEntryId,
      'strength_condition',
    );

    if (mounted) {
      setState(() {
        hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Training data saved successfully'),
          duration: Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _autoSaveData() async {
    if (!mounted) return;
    try {
      await StorageService.saveTrainingEntries(
        trainingEntries,
        nextEntryId,
        'strength_condition',
      );
      if (mounted) {
        setState(() {
          hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Silently fail for auto-save
    }
  }

  Future<void> _showSaveSessionDialog() async {
    if (trainingEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No training entries to save'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    // Auto-save with exercise name as session name
    final sessionName = widget.selectedExercise?.label ?? 'Training Session';
    
    try {
      // Filter entries to only include stats for the selected exercise
      final filteredEntries = _filterEntriesForCurrentExercise();
      
      await StorageService.saveStrengthTrainingSession(
        sessionName,
        filteredEntries,
        nextEntryId,
        playerId: widget.player.id,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Session "$sessionName" saved'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving session: $e'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  /// Filter training entries to only include stats for the currently selected exercise
  List<TrainingEntry> _filterEntriesForCurrentExercise() {
    if (widget.selectedExercise == null) {
      return trainingEntries; // Return all if no exercise selected
    }

    final exerciseKey = widget.selectedExercise!.key;
    
    return trainingEntries.map((entry) {
      // Create a new entry with filtered custom stats
      final filteredStats = <String, int>{};
      
      for (final stat in entry.customStats.entries) {
        // Keep only stats that belong to the selected exercise
        if (stat.key.startsWith('${exerciseKey}_set') || 
            stat.key.startsWith('${exerciseKey}_left_set') ||
            stat.key.startsWith('${exerciseKey}_right_set')) {
          filteredStats[stat.key] = stat.value;
        }
      }
      
      // Return a copy of the entry with filtered stats
      return entry.copyWith(customStats: filteredStats);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveData();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Strength & Condition Training'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _showSaveSessionDialog,
              tooltip: 'Save training session',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Recording Interface
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trainingEntries.length,
                itemBuilder: (context, index) {
                  final entry = trainingEntries[index];
                  return _ExerciseTrackingCard(
                    entry: entry,
                    selectedExercise: widget.selectedExercise!,
                    onUpdate: () {
                      setState(() {
                        hasUnsavedChanges = true;
                      });
                      _autoSaveData();
                    },
                    onSaveBeforeExit: _autoSaveData,
                    onSaveSession: _showSaveSessionDialog,
                  );
                },
              ),
            ],
          ),
        ),
        ),
    );
  }
}

class _ExerciseTrackingCard extends StatefulWidget {
  final TrainingEntry entry;
  final ExerciseConfig selectedExercise;
  final VoidCallback onUpdate;
  final Future<void> Function() onSaveBeforeExit;
  final Future<void> Function() onSaveSession;

  const _ExerciseTrackingCard({
    required this.entry,
    required this.onUpdate,
    required this.selectedExercise,
    required this.onSaveBeforeExit,
    required this.onSaveSession,
  });

  @override
  State<_ExerciseTrackingCard> createState() => _ExerciseTrackingCardState();
}

class _ExerciseTrackingCardState extends State<_ExerciseTrackingCard> {
  late TrainingEntry entry;
  late ExerciseConfig exercise;
  int currentSet = 1;
  int currentReps = 0;
  bool isLeftLeg = true; // For per-leg exercises
  bool startingLeg = true; // Track which leg was chosen at the start (true=left, false=right)
  int extraSets = 0; // Track additional sets beyond target

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
    exercise = widget.selectedExercise;
    
    // Show leg selection dialog for per-leg exercises
    if (exercise.isPerLeg) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLegSelectionDialog();
      });
    }
  }

  void _showLegSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Starting Leg'),
        content: Text('Which leg do you want to start with for ${exercise.label}?'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () {
              setState(() {
                isLeftLeg = true;
                startingLeg = true;
                currentSet = 1;
                currentReps = 0;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'LEFT LEG',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            onPressed: () {
              setState(() {
                isLeftLeg = false;
                startingLeg = false;
                currentSet = 1;
                currentReps = 0;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'RIGHT LEG',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  ExerciseConfig get selectedExercise => exercise;

  String _getStatKey(String exerciseKey, {bool isLeftLeg = false}) {
    return isLeftLeg ? '${exerciseKey}_left' : exerciseKey;
  }

  void _incrementReps() {
    setState(() {
      currentReps++;
    });
    widget.onUpdate();
  }

  void _decrementReps() {
    if (currentReps > 0) {
      setState(() {
        currentReps--;
      });
      widget.onUpdate();
    }
  }

  void _completeSet() {
    // For per-leg exercises, use the leg-specific key; for others, use just the exercise key
    final statKey = selectedExercise.isPerLeg 
        ? _getStatKey(exercise.key, isLeftLeg: isLeftLeg)
        : exercise.key;
    final repsKey = '${statKey}_set$currentSet';
    
    // For Crab Walk, record the target value instead of progressive count
    if (exercise.key == 'crabWalk') {
      entry.customStats[repsKey] = exercise.targetReps;
    } else {
      entry.customStats[repsKey] = currentReps;
    }

    final totalTargetSets = exercise.targetSets + extraSets;

    // Handle per-leg exercises differently
    if (selectedExercise.isPerLeg) {
      if (isLeftLeg == startingLeg) {
        // First leg of the set done, switch to other leg
        setState(() {
          isLeftLeg = !isLeftLeg;
          currentReps = 0;
        });
      } else {
        // Second leg done, move to next set
        if (currentSet < totalTargetSets) {
          setState(() {
            currentSet++;
            isLeftLeg = startingLeg;
            currentReps = 0;
          });
        } else {
          // All sets completed
          _showCompletionSummary();
        }
      }
    } else {
      // Non-per-leg exercises
      if (currentSet < totalTargetSets) {
        setState(() {
          currentSet++;
          currentReps = 0;
        });
      } else {
        // Exercise completed
        _showCompletionSummary();
      }
    }
    widget.onUpdate();
  }



  void _addAnotherSet() {
    Navigator.pop(context); // Close the summary dialog
    setState(() {
      extraSets++;
      currentSet++;
      isLeftLeg = startingLeg; // Reset to starting leg for the new set
      currentReps = 0;
    });
  }

  void _showCompletionSummary() {
    final sets = <String>[];
    final totalSets = exercise.targetSets + extraSets;

    if (exercise.isPerLeg) {
      for (int i = 1; i <= totalSets; i++) {
        final leftKey = _getStatKey(exercise.key, isLeftLeg: true);
        final rightKey = _getStatKey(exercise.key, isLeftLeg: false);
        final leftReps = entry.customStats['${leftKey}_set$i'] ?? 0;
        final rightReps = entry.customStats['${rightKey}_set$i'] ?? 0;
        sets.add('Set $i: L=$leftReps, R=$rightReps');
      }
    } else {
      for (int i = 1; i <= totalSets; i++) {
        final value = entry.customStats['${exercise.key}_set$i'] ?? 0;
        if (exercise.key == 'crabWalk') {
          sets.add('Set $i: Done');
        } else {
          sets.add('Set $i: $value ${exercise.unit}');
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${exercise.label} Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...sets.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(s),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _addAnotherSet,
            child: const Text('Add a Set'),
          ),
          TextButton(
            onPressed: () async {
              await widget.onSaveSession();
              Navigator.pop(context); // Close the summary dialog
              Navigator.pop(context); // Go back to exercise selection screen
            },
            child: const Text('Start Another Exercise'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = selectedExercise;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player header - read-only display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              '#${entry.playerNumber} - ${entry.playerName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Exercise name (no selector since only one is passed)
          Text(
            exercise.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          ...[
            // Target info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise.isPerLeg
                        ? 'Target: ${exercise.targetReps} per leg × ${exercise.targetSets} sets'
                        : 'Target: ${exercise.targetReps} ${exercise.unit} × ${exercise.targetSets} sets',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (exercise.isPerLeg && isLeftLeg)
                    InkWell(
                      onTap: _showLegSelectionDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'LEFT LEG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  else if (exercise.isPerLeg && !isLeftLeg)
                    InkWell(
                      onTap: _showLegSelectionDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'RIGHT LEG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Set progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set $currentSet of ${exercise.targetSets + extraSets}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: currentSet / (exercise.targetSets + extraSets),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // For Crab Walk: Simple Done button
            if (exercise.key == 'crabWalk')
              Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: _completeSet,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            // For other exercises: Rep counter
            else
              Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          exercise.isPerLeg
                              ? 'Reps This Set'
                              : '${exercise.unit[0].toUpperCase()}${exercise.unit.substring(1)} This Set',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.shade300,
                              width: 3,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _incrementReps,
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: Text(
                                  '$currentReps',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Deduct button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _decrementReps,
                          child: const Text(
                            '- Deduct Rep',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Complete set button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _completeSet,
                      child: const Text(
                        'Complete Set',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}
