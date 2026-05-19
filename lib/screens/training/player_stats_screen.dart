import 'package:flutter/material.dart';
import '../../models/training_player.dart';
import '../../models/training_entry.dart';
import '../../services/storage_service.dart';

class PlayerStatsScreen extends StatefulWidget {
  final TrainingPlayer player;

  const PlayerStatsScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<TrainingEntry>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyFuture = _loadPlayerHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<TrainingEntry>> _loadPlayerHistory() async {
    final history = await StorageService.getPlayerTrainingHistory(widget.player.id);
    // Convert raw dynamic objects to TrainingEntry if needed
    return history.map((e) {
      if (e is TrainingEntry) {
        return e;
      } else if (e is Map<String, dynamic>) {
        return TrainingEntry.fromJson(e);
      }
      return e as TrainingEntry;
    }).toList();
  }

  Future<void> _deleteEntry(TrainingEntry entry, String trainingType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Delete this training entry?'),
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
      final data = await StorageService.loadTrainingEntries(trainingType);
      final entries = (data['entries'] as List).cast<TrainingEntry>();
      entries.removeWhere((e) => e.id == entry.id);
      
      await StorageService.saveTrainingEntries(
        entries,
        data['nextId'] as int,
        trainingType,
      );

      if (mounted) {
        setState(() {
          _historyFuture = _loadPlayerHistory();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.player.name} - Training History'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Strength & Condition'),
            Tab(text: 'Technical Performance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStrengthHistoryTab(),
          _buildTechnicalHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildStrengthHistoryTab() {
    return FutureBuilder<List<TrainingEntry>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allEntries = snapshot.data ?? [];
        final strengthEntries = allEntries
            .where((e) => e.trainingType == 'strength_condition')
            .toList();

        if (strengthEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Strength Training Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete some strength exercises to see records',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Sort by date (newest first)
        strengthEntries.sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: strengthEntries.length,
          itemBuilder: (context, index) {
            final entry = strengthEntries[index];
            return _buildStrengthEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildTechnicalHistoryTab() {
    return FutureBuilder<List<TrainingEntry>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allEntries = snapshot.data ?? [];
        final technicalEntries = allEntries
            .where((e) => e.trainingType == 'technical_performance')
            .toList();

        if (technicalEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Technical Performance Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete some technical exercises to see records',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Sort by date (newest first)
        technicalEntries.sort((a, b) => b.date.compareTo(a.date));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: technicalEntries.length,
          itemBuilder: (context, index) {
            final entry = technicalEntries[index];
            return _buildTechnicalEntryCard(entry);
          },
        );
      },
    );
  }

  Widget _buildStrengthEntryCard(TrainingEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      _deleteEntry(entry, 'strength_condition'),
                  color: Colors.red,
                  iconSize: 20,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Exercise Data',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (entry.customStats.isEmpty)
              Text(
                'No exercise data recorded',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entry.customStats.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${e.value}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                entry.notes,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalEntryCard(TrainingEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(entry.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      _deleteEntry(entry, 'technical_performance'),
                  color: Colors.red,
                  iconSize: 20,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Skill Ratings',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (entry.customStats.isEmpty)
              Text(
                'No skill ratings recorded',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entry.customStats.entries.map((e) {
                  final rating = e.value;
                  final color = _getRatingColor(rating);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '$rating/10',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: rating / 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                entry.notes,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getRatingColor(int rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.blue;
    if (rating >= 4) return Colors.orange;
    return Colors.red;
  }
}
