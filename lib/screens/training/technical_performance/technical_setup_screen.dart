import 'package:flutter/material.dart';
import '../../../models/stat_type.dart';
import '../../../models/training_player.dart';
import 'technical_performance_screen.dart';

class TechnicalSetupScreen extends StatefulWidget {
  final List<StatType> statTypes;
  final TrainingPlayer player;

  const TechnicalSetupScreen({
    Key? key,
    required this.statTypes,
    required this.player,
  }) : super(key: key);

  @override
  State<TechnicalSetupScreen> createState() => _TechnicalSetupScreenState();
}

class _TechnicalSetupScreenState extends State<TechnicalSetupScreen> {
  late StatType selectedStat;
  bool hasConfiguredTarget = false;

  @override
  void initState() {
    super.initState();
    selectedStat = widget.statTypes.first;
  }

  void _selectStatAndConfigure(StatType stat) {
    setState(() {
      selectedStat = stat;
      hasConfiguredTarget = true;
    });
  }

  void _startTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TechnicalPerformanceScreen(
          selectedStat: selectedStat,
          player: widget.player,
        ),
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
      ),
      body: Padding(
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
              child: ListView.builder(
                itemCount: widget.statTypes.length,
                itemBuilder: (context, index) {
                  final stat = widget.statTypes[index];
                  final isSelected = selectedStat.key == stat.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectStatAndConfigure(stat),
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
                                    color: isSelected && hasConfiguredTarget
                                        ? Colors.green
                                        : isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected && hasConfiguredTarget
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
                                      stat.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (isSelected && !hasConfiguredTarget)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Tap to select',
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
                  backgroundColor: hasConfiguredTarget ? Colors.green : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: hasConfiguredTarget ? _startTraining : null,
                child: Text(
                  hasConfiguredTarget
                      ? 'Start Training'
                      : 'Select Skill to Track',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasConfiguredTarget ? Colors.white : Colors.grey.shade600,
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
