import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/training_player.dart';
import '../../../services/storage_service.dart';
import '../../../core/services/export/export_service.dart';
import '../../../core/services/export/txt_export_strategy.dart';
import '../../../core/services/export/excel_export_strategy.dart';
import '../../../core/services/export/training_export_helper.dart';
import 'player_stats_screen.dart';

class TrainingPlayerSelectionScreen extends StatefulWidget {
  const TrainingPlayerSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TrainingPlayerSelectionScreen> createState() =>
      _TrainingPlayerSelectionScreenState();
}

class _TrainingPlayerSelectionScreenState
    extends State<TrainingPlayerSelectionScreen> {
  late Future<List<TrainingPlayer>> _playersFuture;
  TrainingPlayer? _selectedPlayer;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() {
    _playersFuture = _getTrainingPlayers();
  }

  Future<List<TrainingPlayer>> _getTrainingPlayers() async {
    try {
      final playersJson = await StorageService.loadTrainingPlayers();
      final players = playersJson
          .map((json) => TrainingPlayer.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by creation date (newest first)
      players.sort((a, b) => b.createdDate.compareTo(a.createdDate));

      // Load active player
      final activePlayerId =
          await StorageService.getActiveTrainingPlayerId();
      if (activePlayerId != null && players.isNotEmpty) {
        _selectedPlayer = players.firstWhere(
          (p) => p.id == activePlayerId,
          orElse: () => players.first,
        );
      }

      return players;
    } catch (e) {
      return [];
    }
  }

  Future<void> _createNewPlayer() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    String selectedPosition = 'CF';

    final positions = StorageService.getDefaultPositions();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Player'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter player name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Jersey Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter jersey number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  initialValue: selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  items: positions
                      .map((pos) => DropdownMenuItem(
                            value: pos.key,
                            child: Text(pos.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPosition = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newPlayer = TrainingPlayer(
        id: const Uuid().v4(),
        name: nameController.text,
        number: int.parse(numberController.text),
        position: selectedPosition,
      );

      final players = await _playersFuture;
      await StorageService.saveTrainingPlayers([...players, newPlayer]);
      await StorageService.setActiveTrainingPlayerId(newPlayer.id);

      if (mounted) {
        setState(() {
          _selectedPlayer = newPlayer;
          _loadPlayers();
        });
      }
    }
  }

  Future<void> _selectPlayer(TrainingPlayer player) async {
    await StorageService.setActiveTrainingPlayerId(player.id);
    if (mounted) {
      setState(() {
        _selectedPlayer = player;
      });
    }
  }

  void _viewPlayerStats(TrainingPlayer player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerStatsScreen(player: player),
      ),
    );
  }

  Future<void> _deletePlayer(TrainingPlayer player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Delete ${player.name} and all their training records?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteTrainingPlayer(player.id);
      if (mounted) {
        setState(() {
          if (_selectedPlayer?.id == player.id) {
            _selectedPlayer = null;
          }
          _loadPlayers();
        });
      }
    }
  }

  Future<void> _exportPlayerData(TrainingPlayer player) async {
    // Show export options dialog
    final exportType = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Training Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select data to export for ${player.name}:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fitness_center, color: Colors.red),
              title: const Text('Strength & Condition Only'),
              onTap: () => Navigator.pop(context, 'strength'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sports_soccer, color: Colors.green),
              title: const Text('Technical Performance Only'),
              onTap: () => Navigator.pop(context, 'technical'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.all_inclusive, color: Colors.purple),
              title: const Text('Both (Complete Export)'),
              onTap: () => Navigator.pop(context, 'both'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (exportType == null) return;

    // Load the data based on selection
    final includeStrength = exportType == 'strength' || exportType == 'both';
    final includeTechnical = exportType == 'technical' || exportType == 'both';

    List<Map<String, dynamic>>? strengthSessions;
    List<Map<String, dynamic>>? technicalSessions;

    if (includeStrength) {
      strengthSessions = await StorageService.loadSavedStrengthTrainingSessions(
        playerId: player.id,
      );
    }

    if (includeTechnical) {
      technicalSessions = await StorageService.loadSavedTechnicalTrainingSessions(
        playerId: player.id,
      );
    }

    // Check if there's any data to export
    final hasStrengthData = strengthSessions != null && strengthSessions.isNotEmpty;
    final hasTechnicalData = technicalSessions != null && technicalSessions.isNotEmpty;

    if (!hasStrengthData && !hasTechnicalData) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No training data available to export'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
      return;
    }

    // Show format selection dialog
    final exportFormat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Text File (.txt)'),
              onTap: () => Navigator.pop(context, 'txt'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel File (.xlsx)'),
              onTap: () => Navigator.pop(context, 'excel'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (exportFormat == null) return;

    try {
      final exportService = ExportService();
      final fileName = 'training_${player.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

      if (exportFormat == 'excel') {
        // Generate Excel data
        final excelData = TrainingExportHelper.generateTrainingDataExcel(
          playerName: player.name,
          playerNumber: player.number,
          position: player.position,
          includeStrength: includeStrength,
          includeTechnical: includeTechnical,
          strengthSessions: strengthSessions,
          technicalSessions: technicalSessions,
        );

        await exportService.exportAndShare(
          data: excelData,
          strategy: ExcelExportStrategy(),
          fileName: fileName,
          subject: 'Training Data Export',
        );
      } else {
        // Generate text data
        final textData = TrainingExportHelper.generateTrainingDataText(
          playerName: player.name,
          playerNumber: player.number,
          position: player.position,
          includeStrength: includeStrength,
          includeTechnical: includeTechnical,
          strengthSessions: strengthSessions,
          technicalSessions: technicalSessions,
        );

        await exportService.exportAndShare(
          data: textData,
          strategy: TxtExportStrategy(),
          fileName: fileName,
          subject: 'Training Data Export',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training data exported successfully!'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  Future<void> _proceedToTraining() async {
    if (_selectedPlayer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a player')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/training',
      arguments: _selectedPlayer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Training Players'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<TrainingPlayer>>(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Players Yet',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a player to start training',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isSelected = _selectedPlayer?.id == player.id;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: ListTile(
                              onTap: () => _selectPlayer(player),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    player.number.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                              title: Text(
                                player.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                              ),
                              subtitle: Text(player.position),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.bar_chart_outlined),
                                        SizedBox(width: 12),
                                        Text('View Stats'),
                                      ],
                                    ),
                                    onTap: () => _viewPlayerStats(player),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.file_download_outlined),
                                        SizedBox(width: 12),
                                        Text('Export Data'),
                                      ],
                                    ),
                                    onTap: () => _exportPlayerData(player),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete_outline, color: Colors.red),
                                        SizedBox(width: 12),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    onTap: () => _deletePlayer(player),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _proceedToTraining,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          _selectedPlayer == null
                              ? 'Select Player to Continue'
                              : 'Start Training with ${_selectedPlayer!.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _createNewPlayer,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Create New Player'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
