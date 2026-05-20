import 'package:flutter/material.dart';
import '../../../models/technical_skill.dart';
import '../../../services/storage_service.dart';

class TechnicalSettingsScreen extends StatefulWidget {
  final List<TechnicalSkill> skills;
  final Function(List<TechnicalSkill>) onSkillsChanged;

  const TechnicalSettingsScreen({
    Key? key,
    required this.skills,
    required this.onSkillsChanged,
  }) : super(key: key);

  @override
  State<TechnicalSettingsScreen> createState() => _TechnicalSettingsScreenState();
}

class _TechnicalSettingsScreenState extends State<TechnicalSettingsScreen> {
  late List<TechnicalSkill> skills;

  @override
  void initState() {
    super.initState();
    skills = List.from(widget.skills);
  }

  Future<void> _saveSkills() async {
    final skillsData = skills.map((skill) => skill.toJson()).toList();
    await StorageService.saveTechnicalSkills(skillsData);
    widget.onSkillsChanged(skills);
  }

  void _editSkill(int index, TechnicalSkill skill) {
    showDialog(
      context: context,
      builder: (context) => _EditSkillDialog(
        skill: skill,
        onUpdate: (updated) async {
          setState(() {
            skills[index] = updated;
          });
          await _saveSkills();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) => _AddSkillDialog(
        onAdd: (newSkill) async {
          setState(() {
            skills.add(newSkill);
          });
          await _saveSkills();
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteSkill(int index) {
    final removed = skills[index];
    setState(() {
      skills.removeAt(index);
    });
    _saveSkills();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted skill "${removed.label}"'),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Technical Skill Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          return Card(
            child: ListTile(
              title: Text(skill.label),
              subtitle: Text(
                'Target Score ${skill.targetScore} • ${skill.totalReps} ${skill.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editSkill(index, skill),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Skill'),
                          content: Text('Delete "${skill.label}"?'),
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
                                _deleteSkill(index);
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
        onPressed: _addSkill,
        tooltip: 'Add new skill',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EditSkillDialog extends StatefulWidget {
  final TechnicalSkill skill;
  final Function(TechnicalSkill) onUpdate;

  const _EditSkillDialog({
    required this.skill,
    required this.onUpdate,
  });

  @override
  State<_EditSkillDialog> createState() => _EditSkillDialogState();
}

class _EditSkillDialogState extends State<_EditSkillDialog> {
  late TextEditingController labelController;
  late int selectedScore;
  late TextEditingController repsController;
  late TextEditingController unitController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController(text: widget.skill.label);
    selectedScore = widget.skill.targetScore;
    repsController = TextEditingController(text: widget.skill.totalReps.toString());
    unitController = TextEditingController(text: widget.skill.unit);
  }

  @override
  void dispose() {
    labelController.dispose();
    repsController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Skill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Skill Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedScore,
              decoration: const InputDecoration(labelText: 'Target score'),
              items: List.generate(
                10,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedScore = value ?? selectedScore;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total reps'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Unit', hintText: 'reps'),
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
            if (labelController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a skill name'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            final reps = int.tryParse(repsController.text) ?? 0;
            if (reps < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Total reps must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            widget.onUpdate(
              TechnicalSkill(
                key: widget.skill.key,
                label: labelController.text.trim(),
                targetScore: selectedScore,
                totalReps: reps,
                unit: unitController.text.trim().isEmpty ? 'reps' : unitController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddSkillDialog extends StatefulWidget {
  final Function(TechnicalSkill) onAdd;

  const _AddSkillDialog({required this.onAdd});

  @override
  State<_AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<_AddSkillDialog> {
  late TextEditingController labelController;
  late int selectedScore;
  late TextEditingController repsController;
  late TextEditingController unitController;

  @override
  void initState() {
    super.initState();
    labelController = TextEditingController();
    selectedScore = 5;
    repsController = TextEditingController(text: '10');
    unitController = TextEditingController(text: 'reps');
  }

  @override
  void dispose() {
    labelController.dispose();
    repsController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Skill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Skill Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: selectedScore,
              decoration: const InputDecoration(labelText: 'Target score'),
              items: List.generate(
                10,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedScore = value ?? selectedScore;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total reps'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: 'Unit', hintText: 'reps'),
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
            final label = labelController.text.trim();
            if (label.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a skill name'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            final reps = int.tryParse(repsController.text) ?? 0;
            if (reps < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Total reps must be at least 1'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
              return;
            }
            widget.onAdd(
              TechnicalSkill(
                key: 'technical_skill_${DateTime.now().millisecondsSinceEpoch}',
                label: label,
                targetScore: selectedScore,
                totalReps: reps,
                unit: unitController.text.trim().isEmpty ? 'reps' : unitController.text.trim(),
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
