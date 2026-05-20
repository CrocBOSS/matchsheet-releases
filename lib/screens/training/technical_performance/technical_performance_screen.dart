import 'package:flutter/material.dart';
import '../../../models/training_entry.dart';
import '../../../models/stat_type.dart';
import '../../../models/training_player.dart';
import '../../../services/storage_service.dart';

class TechnicalPerformanceScreen extends StatefulWidget {
  final StatType? selectedStat;
  final int? targetScore;
  final int? totalReps;
  final TrainingPlayer player;

  static final List<StatType> technicalStatTypes = [
    StatType(key: 'skillsAndComposure', label: 'Skills and Composure'),
    StatType(key: 'aggression', label: 'Aggression'),
    StatType(key: 'longThrows', label: 'Long Throws'),
    StatType(key: 'distributionAccuracy', label: 'Distribution Accuracy'),
    StatType(key: 'weakFoot', label: 'Weak Foot'),
    StatType(key: 'scanningAwareness', label: 'Scanning and Awareness'),
    StatType(key: 'targetPractice', label: 'Target Practice'),
    StatType(key: 'defensiveHeader', label: 'Defensive Header'),
    StatType(key: 'followUpBalls', label: 'Follow up balls'),
    StatType(key: 'throughPasses', label: 'Through passes'),
    StatType(key: 'lineDominance', label: 'Line Dominance'),
    StatType(key: 'speed', label: 'Speed'),
    StatType(key: 'longPasses', label: 'Long Passes'),
    StatType(key: 'firstTouch', label: 'First Touch'),
    StatType(key: 'killerInstinct', label: 'Killer Instinct'),
    StatType(key: 'communication', label: 'Communication'),
    StatType(key: 'overConfidence', label: 'Over Confidence'),
    StatType(key: 'oneVOneSituations', label: '1v1 Situations'),
    StatType(key: 'agility', label: 'Agility'),
    StatType(key: 'turning', label: 'Turning'),
    StatType(key: 'shooting', label: 'Shooting'),
    StatType(key: 'crossing', label: 'Crossing'),
    StatType(key: 'volleyShots', label: 'Volley shots'),
    StatType(key: 'positioning', label: 'Positioning'),
    StatType(key: 'defensiveMindset', label: 'Defensive Mindset'),
  ];

  const TechnicalPerformanceScreen({
    Key? key,
    this.selectedStat,
    this.targetScore,
    this.totalReps,
    required this.player,
  }) : super(key: key);

  @override
  State<TechnicalPerformanceScreen> createState() => _TechnicalPerformanceScreenState();
}

class _TechnicalPerformanceScreenState extends State<TechnicalPerformanceScreen> {
  List<TrainingEntry> trainingEntries = [];
  List<StatType> statTypes = [];
  int nextEntryId = 1;
  bool hasUnsavedChanges = false;
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    statTypes = TechnicalPerformanceScreen.technicalStatTypes;
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await StorageService.loadTrainingEntries('technical_performance');
    final allEntries = data['entries'] as List<TrainingEntry>;
    
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
      trainingType: 'technical_performance',
      customStats: {
        if (widget.selectedStat != null && widget.targetScore != null)
          '${widget.selectedStat!.key}_targetScore': widget.targetScore!,
        if (widget.selectedStat != null && widget.totalReps != null)
          '${widget.selectedStat!.key}_totalReps': widget.totalReps!,
      },
    );

    setState(() {
      trainingEntries.add(newEntry);
      nextEntryId++;
      hasUnsavedChanges = true;
    });
    
    _autoSaveData();
  }

  Future<void> _saveData() async {
    if (trainingEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No training entries to save'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    await StorageService.saveTrainingEntries(
      trainingEntries,
      nextEntryId,
      'technical_performance',
    );
    
    if (mounted) {
      setState(() {
        hasUnsavedChanges = false;
      });
      final skillName = widget.selectedStat?.label ?? 'Training';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ $skillName data saved'),
          duration: const Duration(milliseconds: 1500),
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
        'technical_performance',
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
          title: const Text('Technical Performance Training'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveData,
              tooltip: 'Save training data',
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.selectedStat == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: Row(
                    children: [
                      for (final stat in statTypes)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            stat.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracking: ${widget.selectedStat!.label}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.targetScore != null && widget.totalReps != null)
                      Text(
                        'Target score: ${widget.targetScore} • Total reps: ${widget.totalReps}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: trainingEntries.length,
                itemBuilder: (context, index) {
                  final entry = trainingEntries[index];
                  return _TrainingEntryCard(
                    entry: entry,
                    statTypes: widget.selectedStat != null
                        ? [widget.selectedStat!]
                        : statTypes,
                    selectedStat: widget.selectedStat,
                    onUpdate: () {
                      setState(() {
                        hasUnsavedChanges = true;
                      });
                      _autoSaveData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingEntryCard extends StatefulWidget {
  final TrainingEntry entry;
  final List<StatType> statTypes;
  final StatType? selectedStat;
  final VoidCallback onUpdate;

  const _TrainingEntryCard({
    required this.entry,
    required this.statTypes,
    required this.onUpdate,
    this.selectedStat,
  });

  @override
  State<_TrainingEntryCard> createState() => _TrainingEntryCardState();
}

class _TrainingEntryCardState extends State<_TrainingEntryCard> {
  late TrainingEntry entry;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${entry.playerNumber} - ${entry.playerName}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.position,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final stat in widget.statTypes)
                _StatInput(
                  label: stat.label,
                  value: entry.customStats[stat.key] ?? 0,
                  onChanged: (newValue) {
                    setState(() {
                      entry.customStats[stat.key] = newValue;
                    });
                    widget.onUpdate();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              entry.notes = value;
              widget.onUpdate();
            },
          ),
        ],
      ),
    );
  }
}

class _StatInput extends StatefulWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const _StatInput({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_StatInput> createState() => _StatInputState();
}

class _StatInputState extends State<_StatInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: (value) {
          final intValue = int.tryParse(value) ?? 0;
          widget.onChanged(intValue);
        },
      ),
    );
  }
}
