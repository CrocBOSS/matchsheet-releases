import 'package:flutter/material.dart';
import '../../../models/technical_skill.dart';
import '../../../models/training_player.dart';
import '../../../services/storage_service.dart';
import 'technical_performance_screen.dart';
import 'technical_settings_screen.dart';
import 'saved_training_screen.dart';

class TechnicalSetupScreen extends StatefulWidget {
  final TrainingPlayer player;

  const TechnicalSetupScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<TechnicalSetupScreen> createState() => _TechnicalSetupScreenState();
}

class _TechnicalSetupScreenState extends State<TechnicalSetupScreen> {
  List<TechnicalSkill> skills = [];
  TechnicalSkill? selectedSkill;
  double selectedTargetScore = 5.0;
  int selectedTotalReps = 10;
  String selectedUnit = 'reps';
  bool hasConfiguredTargets = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills({bool preserveSelection = false}) async {
    final skillsData = await StorageService.loadTechnicalSkills();
    final loadedSkills = skillsData
        .map((e) => TechnicalSkill.fromJson(e))
        .toList();

    if (!mounted) return;

    setState(() {
      skills = loadedSkills;
      if (skills.isNotEmpty) {
        if (preserveSelection && selectedSkill != null) {
          selectedSkill = skills.firstWhere(
            (s) => s.key == selectedSkill!.key,
            orElse: () => skills.first,
          );
        } else {
          selectedSkill = skills.first;
        }
      } else {
        selectedSkill = null;
      }
      if (selectedSkill != null) {
        selectedTargetScore = selectedSkill!.targetScore.toDouble();
        selectedTotalReps = selectedSkill!.totalReps;
        selectedUnit = selectedSkill!.unit;
      }
      hasConfiguredTargets = false;
      isLoading = false;
    });
  }

  void _selectSkillAndConfigure(TechnicalSkill skill) {
    setState(() {
      selectedSkill = skill;
      selectedTargetScore = skill.targetScore.toDouble();
      selectedTotalReps = skill.totalReps;
      selectedUnit = skill.unit;
      hasConfiguredTargets = false;
    });
    _showSkillConfigDialog(skill);
  }

  void _showSkillConfigDialog(TechnicalSkill skill) {
    final repsController = TextEditingController(text: selectedTotalReps.toString());
    final unitController = TextEditingController(text: selectedUnit);
    double scoreValue = selectedTargetScore;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${skill.label}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<double>(
                initialValue: scoreValue,
                decoration: const InputDecoration(
                  labelText: 'Target score',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  20,
                  (index) {
                    final value = (index + 1) * 0.5;
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value == value.toInt() ? '${value.toInt()}' : '$value'),
                    );
                  },
                ),
                onChanged: (value) {
                  scoreValue = value ?? scoreValue;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total reps',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'reps',
                  border: OutlineInputBorder(),
                ),
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
              final repsValue = int.tryParse(repsController.text) ?? 0;
              final unitValue = unitController.text.trim().isEmpty ? 'reps' : unitController.text.trim();

              if (scoreValue < 0.5 || scoreValue > 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Score must be between 0.5 and 10'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
                return;
              }

              if (repsValue < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Total reps must be at least 1'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
                return;
              }

              setState(() {
                selectedTargetScore = scoreValue;
                selectedTotalReps = repsValue;
                selectedUnit = unitValue;
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
    if (selectedSkill == null || !hasConfiguredTargets) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechnicalPerformanceScreen(
          selectedStat: selectedSkill!.toStatType(),
          targetScore: selectedTargetScore,
          totalReps: selectedTotalReps,
          player: widget.player,
        ),
      ),
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechnicalSettingsScreen(
          skills: skills,
          onSkillsChanged: (updatedSkills) {
            setState(() {
              skills = updatedSkills;
            });
          },
        ),
      ),
    );
    await _loadSkills(preserveSelection: true);
  }

  void _openSavedTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedTechnicalTrainingScreen(player: widget.player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Select Skill'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Technical skill settings',
            onPressed: _openSettings,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Skill to Track',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: skills.isEmpty
                  ? Center(
                      child: Text(
                        'No technical skills configured yet. Open settings to add skills.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        final skill = skills[index];
                        final isSelected = selectedSkill?.key == skill.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _selectSkillAndConfigure(skill),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(context).colorScheme.primary,
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
                                          color: isSelected
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
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            skill.label,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isSelected && hasConfiguredTargets
                                                ? 'Target Score $selectedTargetScore • $selectedTotalReps $selectedUnit'
                                                : 'Target Score ${skill.targetScore} • ${skill.totalReps} ${skill.unit}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Tap to configure',
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.primary,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 12),
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
                      : 'Tap a skill to configure targets',
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
