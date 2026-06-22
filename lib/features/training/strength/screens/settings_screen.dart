import 'package:flutter/material.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/exercise_config_service.dart';
import 'strength_screen.dart';

class StrengthSettingsScreen extends StatefulWidget {
  final List<ExerciseConfig> exercises;
  final Function(List<ExerciseConfig>) onExercisesChanged;

  const StrengthSettingsScreen({
    Key? key,
    required this.exercises,
    required this.onExercisesChanged,
  }) : super(key: key);

  @override
  State<StrengthSettingsScreen> createState() => _StrengthSettingsScreenState();
}

class _StrengthSettingsScreenState extends State<StrengthSettingsScreen> {
  late List<ExerciseConfig> exercises;

  @override
  void initState() {
    super.initState();
    exercises = List.from(widget.exercises);
  }

  void _editExercise(int index, ExerciseConfig exercise) async {
    setState(() {
      exercises[index] = exercise;
    });
    widget.onExercisesChanged(exercises);
    await _saveExercises();
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onAdd: (newExercise) async {
          setState(() {
            exercises.add(newExercise);
          });
          widget.onExercisesChanged(exercises);
          await _saveExercises();
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _saveExercises() async {
    final exercisesData = exercises
        .map((e) => {
              'key': e.key,
              'label': e.label,
              'targetReps': e.targetReps,
              'targetSets': e.targetSets,
              'isPerLeg': e.isPerLeg,
              'unit': e.unit,
            })
        .toList();
    await StorageService.saveStrengthExercises(exercisesData);
    // Clear the exercise config cache so updated names/units appear everywhere
    ExerciseConfigService.clearCache();
  }

  void _deleteExercise(int index) {
    setState(() {
      exercises.removeAt(index);
    });
    widget.onExercisesChanged(exercises);
    _saveExercises();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exercise deleted'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Strength & Condition Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            child: ListTile(
              title: Text(exercise.label),
              subtitle: Text(
                '${exercise.targetReps} ${exercise.unit} × ${exercise.targetSets} sets${exercise.isPerLeg ? ' (per leg)' : ''}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _EditExerciseDialog(
                          exercise: exercise,
                          onUpdate: (updated) {
                            _editExercise(index, updated);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Exercise'),
                          content: Text('Are you sure you want to delete ${exercise.label}?'),
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
                                _deleteExercise(index);
                                Navigator.pop(context);
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        tooltip: 'Add new exercise',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EditExerciseDialog extends StatefulWidget {
  final ExerciseConfig exercise;
  final Function(ExerciseConfig) onUpdate;

  const _EditExerciseDialog({
    required this.exercise,
    required this.onUpdate,
  });

  @override
  State<_EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late TextEditingController labelController;
  late TextEditingController repsController;
  late TextEditingController setsController;
  late TextEditingController unitController;
  late bool isPerLeg;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.exercise.label);
    repsController = TextEditingController(text: widget.exercise.targetReps.toString());
    setsController = TextEditingController(text: widget.exercise.targetSets.toString());
    unitController = TextEditingController(text: widget.exercise.unit);
    isPerLeg = widget.exercise.isPerLeg;
  }

  @override
  void dispose() {
    labelController.dispose();
    repsController.dispose();
    setsController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Reps/Value'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Sets'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (e.g. reps, meters)',
                hintText: 'reps',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Per Leg Exercise'),
              value: isPerLeg,
              onChanged: (value) {
                setState(() {
                  isPerLeg = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final targetReps = int.tryParse(repsController.text) ?? widget.exercise.targetReps;
            final targetSets = int.tryParse(setsController.text) ?? widget.exercise.targetSets;
            
            if (targetReps < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Target reps must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            
            if (targetSets < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Target sets must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            
            widget.onUpdate(ExerciseConfig(
              key: widget.exercise.key,
              label: labelController.text.isEmpty ? widget.exercise.label : labelController.text,
              targetReps: targetReps,
              targetSets: targetSets,
              isPerLeg: isPerLeg,
              unit: unitController.text.isEmpty ? 'reps' : unitController.text,
            ));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final Function(ExerciseConfig) onAdd;

  const _AddExerciseDialog({required this.onAdd});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  late TextEditingController labelController;
  late TextEditingController repsController;
  late TextEditingController setsController;
  late TextEditingController unitController;
  bool isPerLeg = false;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController();
    repsController = TextEditingController();
    setsController = TextEditingController();
    unitController = TextEditingController(text: 'reps');
  }

  @override
  void dispose() {
    labelController.dispose();
    repsController.dispose();
    setsController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Reps/Value'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Sets'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (e.g. reps, meters)',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Per Leg Exercise'),
              value: isPerLeg,
              onChanged: (value) {
                setState(() {
                  isPerLeg = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (labelController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter an exercise name'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            
            final targetReps = int.tryParse(repsController.text) ?? 1;
            final targetSets = int.tryParse(setsController.text) ?? 1;
            
            if (targetReps < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Target reps must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            
            if (targetSets < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Target sets must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            
            widget.onAdd(ExerciseConfig(
              key: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
              label: labelController.text,
              targetReps: targetReps,
              targetSets: targetSets,
              isPerLeg: isPerLeg,
              unit: unitController.text.isEmpty ? 'reps' : unitController.text,
            ));
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
