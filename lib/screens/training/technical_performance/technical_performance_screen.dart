import 'package:flutter/material.dart';
import '../../../models/training_entry.dart';
import '../../../models/stat_type.dart';
import '../../../models/training_player.dart';
import '../../../services/storage_service.dart';

class TechnicalPerformanceScreen extends StatefulWidget {
  final StatType? selectedStat;
  final double? targetScore;
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
  
  // For tracking a single skill
  int successCount = 0;
  int neutralCount = 0;
  int failCount = 0;

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

  double _calculateCurrentScore() {
    final totalAttempts = successCount + neutralCount + failCount;
    final effectiveTotalReps = totalAttempts > (widget.totalReps ?? 0) 
      ? totalAttempts 
      : (widget.totalReps ?? 0);
    
    if (effectiveTotalReps == 0) return 0;
    
    final totalPoints = (successCount * 1.0) + (neutralCount * 0.5) + (failCount * 0.0);
    return (totalPoints / effectiveTotalReps) * 10;
  }

  void _completeTraining() {
    // Just show the modal - saving happens on Done button
    _showCompletionSummary();
  }

  void _showCompletionSummary() {
    final currentScore = _calculateCurrentScore();
    final totalAttempts = successCount + neutralCount + failCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.selectedStat!.label} Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attempts: $totalAttempts',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '✓ Successful: $successCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '⊙ Neutral: $neutralCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '✗ Failed: $failCount',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
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
                    '${currentScore.toStringAsFixed(1)}/10',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save the tracking data
              if (trainingEntries.isNotEmpty) {
                final lastEntry = trainingEntries.last;
                final skillKey = widget.selectedStat!.key;
                
                lastEntry.customStats['${skillKey}_successful'] = successCount;
                lastEntry.customStats['${skillKey}_neutral'] = neutralCount;
                lastEntry.customStats['${skillKey}_fail'] = failCount;
                lastEntry.customStats['${skillKey}_currentScore'] = _calculateCurrentScore();
              }
              
              // Save using the appropriate method
              if (widget.selectedStat != null) {
                await _saveTrainingSession();
              } else {
                await _saveData();
              }
              
              if (mounted) {
                Navigator.pop(context); // Close the summary dialog
                Navigator.pop(context); // Go back to skill selection screen
              }
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTrainingSession() async {
    // Auto-save with skill name as session name
    final sessionName = widget.selectedStat?.label ?? 'Training Session';
    
    try {
      final skillKey = widget.selectedStat!.key;
      
      // Save to storage using the new technical training session method
      await StorageService.saveTechnicalTrainingSession(
        sessionName,
        skillKey,
        widget.selectedStat!.label,
        successCount,
        neutralCount,
        failCount,
        _calculateCurrentScore(),
        playerId: widget.player.id,
        playerNumber: widget.player.number.toString(),
        playerName: widget.player.name,
        targetScore: widget.targetScore,
        totalReps: widget.totalReps,
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
          title: widget.selectedStat != null
              ? Text(widget.selectedStat!.label)
              : const Text('Technical Performance Training'),
          centerTitle: true,
          elevation: 0,
          actions: [
            if (widget.selectedStat == null)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveData,
                tooltip: 'Save training data',
              ),
            if (widget.selectedStat != null)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveTrainingSession,
                tooltip: 'Save training session',
              ),
          ],
        ),
        body: widget.selectedStat != null
            ? _buildSkillTrackingScreen()
            : _buildSkillSelectionScreen(),
      ),
    );
  }

  Widget _buildSkillTrackingScreen() {
    final currentScore = _calculateCurrentScore();
    final totalAttempts = successCount + neutralCount + failCount;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Skill Info Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target Score',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${widget.targetScore}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/10',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Current Scale',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentScore.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: currentScore >= widget.targetScore! ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatBadge('Successful', successCount, Colors.green),
                    _buildStatBadge('Neutral', neutralCount, Colors.orange),
                    _buildStatBadge('Fail', failCount, Colors.red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Buttons Section
          Text(
            'Record Attempt',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildResponsiveRecordButtons(),
          const SizedBox(height: 40),
          
          // Complete Training Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              onPressed: _completeTraining,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Complete Training',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSkillSelectionScreen() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: trainingEntries.length,
            itemBuilder: (context, index) {
              final entry = trainingEntries[index];
              return _TrainingEntryCard(
                entry: entry,
                statTypes: statTypes,
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
    );
  }

  Widget _buildResponsiveRecordButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    
    // Calculate responsive sizes
    final buttonHeight = isLargeScreen ? 180.0 : 120.0;
    final iconSize = isLargeScreen ? 48.0 : 32.0;
    final buttonPadding = isLargeScreen 
      ? const EdgeInsets.symmetric(vertical: 24, horizontal: 16)
      : const EdgeInsets.symmetric(vertical: 20, horizontal: 12);
    const spacing = SizedBox(height: 12);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Success Button
        Expanded(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAF3DE),
                  foregroundColor: const Color(0xFF27500A),
                  elevation: 0,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.fromHeight(buttonHeight),
                ),
                onPressed: () {
                  setState(() {
                    successCount++;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: iconSize),
                    const SizedBox(height: 12),
                    Text(
                      'Successful',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isLargeScreen ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              spacing,
              IconButton(
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  setState(() {
                    if (successCount > 0) successCount--;
                  });
                },
                iconSize: 24,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Neutral Button
        Expanded(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFAEEDA),
                  foregroundColor: const Color(0xFF633806),
                  elevation: 0,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.fromHeight(buttonHeight),
                ),
                onPressed: () {
                  setState(() {
                    neutralCount++;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radio_button_unchecked, size: iconSize),
                    const SizedBox(height: 12),
                    Text(
                      'Neutral',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isLargeScreen ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              spacing,
              IconButton(
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  setState(() {
                    if (neutralCount > 0) neutralCount--;
                  });
                },
                iconSize: 24,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Fail Button
        Expanded(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCEBEB),
                  foregroundColor: const Color(0xFF791F1F),
                  elevation: 0,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.fromHeight(buttonHeight),
                ),
                onPressed: () {
                  setState(() {
                    failCount++;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cancel_outlined, size: iconSize),
                    const SizedBox(height: 12),
                    Text(
                      'Fail',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isLargeScreen ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              spacing,
              IconButton(
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  setState(() {
                    if (failCount > 0) failCount--;
                  });
                },
                iconSize: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
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
