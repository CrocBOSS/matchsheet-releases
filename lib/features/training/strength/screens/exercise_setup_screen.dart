import 'package:flutter/material.dart';
import '../../models/training_player.dart';
import '../../../../services/storage_service.dart';
import 'strength_screen.dart';
import 'settings_screen.dart';
import 'saved_sessions_screen.dart';

class ExerciseSetupScreen extends StatefulWidget {
  final List<ExerciseConfig> exercises;
  final TrainingPlayer player;

  const ExerciseSetupScreen({
    Key? key,
    required this.exercises,
    required this.player,
  }) : super(key: key);

  @override
  State<ExerciseSetupScreen> createState() => _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends State<ExerciseSetupScreen> {
  List<ExerciseConfig> exercises = [];
  ExerciseConfig? selectedExercise;
  bool hasConfiguredTargets = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises({bool preserveSelection = false}) async {
    final exercisesData = await StorageService.loadStrengthExercises();
    final loadedExercises = exercisesData
        .map((e) => ExerciseConfig(
              key: e['key'] as String,
              label: e['label'] as String,
              targetReps: e['targetReps'] as int,
              targetSets: e['targetSets'] as int,
              isPerLeg: e['isPerLeg'] as bool,
              unit: e['unit'] as String? ?? 'reps',
            ))
        .toList();
    
    if (mounted) {
      setState(() {
        exercises = loadedExercises;
        if (exercises.isNotEmpty) {
          // If preserveSelection is true, try to keep the previously selected exercise
          if (preserveSelection && selectedExercise != null && exercises.any((e) => e.key == selectedExercise!.key)) {
            // Keep the current selectedExercise (it's still in the list)
            selectedExercise = exercises.firstWhere((e) => e.key == selectedExercise!.key);
          } else {
            // First load or exercise was deleted: select the first exercise
            selectedExercise = exercises.first;
            hasConfiguredTargets = false;
          }
        }
      });
    }
  }

  void _selectExerciseAndConfigure(ExerciseConfig exercise) {
    setState(() {
      selectedExercise = exercise;
      hasConfiguredTargets = false;
    });
    _showTargetConfigDialog(exercise);
  }

  void _showTargetConfigDialog(ExerciseConfig exercise) {
    final repsController = TextEditingController(
      text: exercise.targetReps.toString(),
    );
    final setsController = TextEditingController(
      text: exercise.targetSets.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${exercise.label}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: exercise.isPerLeg
                    ? 'Target per leg'
                    : 'Target ${exercise.unit}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target sets',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newReps = int.tryParse(repsController.text) ?? exercise.targetReps;
              final newSets = int.tryParse(setsController.text) ?? exercise.targetSets;

              setState(() {
                selectedExercise = ExerciseConfig(
                  key: exercise.key,
                  label: exercise.label,
                  targetReps: newReps,
                  targetSets: newSets,
                  isPerLeg: exercise.isPerLeg,
                  unit: exercise.unit,
                );
                hasConfiguredTargets = true;
              });

              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _startTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrengthAndConditionScreen(
          selectedExercise: selectedExercise,
          player: widget.player,
        ),
      ),
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrengthSettingsScreen(
          exercises: exercises,
          onExercisesChanged: (updatedExercises) {
            // Handle updated exercises if needed
          },
        ),
      ),
    );
    // Reload exercises after returning from settings, but preserve the selected exercise
    await _loadExercises(preserveSelection: true);
  }

  void _openSavedTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedTrainingScreen(player: widget.player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Select Exercise'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'saved_training') {
                _openSavedTraining();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'saved_training',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Saved Training'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
          ),
        ],
      ),
      body: exercises.isEmpty
          ? Center(
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
                    'No exercises available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Exercise',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        final isSelected = selectedExercise?.key == exercise.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectExerciseAndConfigure(exercise),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected && hasConfiguredTargets
                                              ? Colors.green
                                              : isSelected
                                                  ? Theme.of(context).colorScheme.primary
                                                  : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected && hasConfiguredTargets
                                          ? Center(
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          : isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.label,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isSelected && hasConfiguredTargets && selectedExercise != null
                                                ? exercise.isPerLeg
                                                    ? '${selectedExercise!.targetReps} per leg × ${selectedExercise!.targetSets} sets'
                                                    : '${selectedExercise!.targetReps} ${selectedExercise!.unit} × ${selectedExercise!.targetSets} sets'
                                                : exercise.isPerLeg
                                                    ? '${exercise.targetReps} per leg × ${exercise.targetSets} sets'
                                                    : '${exercise.targetReps} ${exercise.unit} × ${exercise.targetSets} sets',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                          if (!(isSelected && hasConfiguredTargets))
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                'Tap to configure targets',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context).colorScheme.primary,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasConfiguredTargets ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: hasConfiguredTargets ? _startTraining : null,
                      child: Text(
                        hasConfiguredTargets
                            ? 'Start Training'
                            : 'Select Exercise & Configure Targets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasConfiguredTargets ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
