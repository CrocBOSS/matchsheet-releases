import 'package:flutter/material.dart';
import '../../models/training_player.dart';
import '../../services/storage_service.dart';
import 'strength_and_condition/strength_and_condition_screen.dart';
import 'strength_and_condition/exercise_setup_screen.dart';
import 'technical_performance/technical_setup_screen.dart';

class TrainingScreen extends StatefulWidget {
  final TrainingPlayer player;

  const TrainingScreen({Key? key, required this.player}) : super(key: key);

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late Future<List<ExerciseConfig>> _strengthExercisesFuture;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    _strengthExercisesFuture = _getStrengthExercises();
  }

  Future<List<ExerciseConfig>> _getStrengthExercises() async {
    final exercisesData = await StorageService.loadStrengthExercises();
    return exercisesData
        .map((e) => ExerciseConfig(
              key: e['key'] as String,
              label: e['label'] as String,
              targetReps: e['targetReps'] as int,
              targetSets: e['targetSets'] as int,
              isPerLeg: e['isPerLeg'] as bool,
              unit: e['unit'] as String? ?? 'reps',
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Training - ${widget.player.name}"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Training Type",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Select Training Category",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  FutureBuilder<List<ExerciseConfig>>(
                    future: _strengthExercisesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _TrainingTypeCard(
                          title: "Strength & Condition",
                          icon: Icons.fitness_center,
                          color: Colors.red,
                          description: "Track conditioning and strength exercises",
                          onTap: () {},
                          isLoading: true,
                        );
                      }

                      final exercises = snapshot.data ?? [];
                      return _TrainingTypeCard(
                        title: "Strength & Condition",
                        icon: Icons.fitness_center,
                        color: Colors.red,
                        description: "Track conditioning and strength exercises",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseSetupScreen(
                                exercises: exercises,
                                player: widget.player,
                              ),
                            ),
                          ).then((_) {
                            // Reload exercises when returning from the screen
                            setState(() {
                              _loadExercises();
                            });
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _TrainingTypeCard(
                    title: "Technical Performance",
                    icon: Icons.sports_soccer,
                    color: Colors.green,
                    description: "Track skill drills and technical exercises",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TechnicalSetupScreen(
                            player: widget.player,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;
  final bool isLoading;

  const _TrainingTypeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
