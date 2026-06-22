import 'package:flutter/material.dart';
import '../models/training_player.dart';
import '../models/training_entry.dart';
import '../../../services/storage_service.dart';

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
  late Future<Map<String, List<Map<String, dynamic>>>> _historyFuture;

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

  Future<Map<String, List<Map<String, dynamic>>>> _loadPlayerHistory() async {
    final strengthSessions = await StorageService.loadSavedStrengthTrainingSessions(
      playerId: widget.player.id,
    );
    final technicalSessions = await StorageService.loadSavedTechnicalTrainingSessions(
      playerId: widget.player.id,
    );

    return {
      'strengthSessions': strengthSessions,
      'technicalSessions': technicalSessions,
    };
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
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final strengthSessions = data['strengthSessions'] ?? [];

        if (strengthSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Strength Training Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Save some strength training sessions to see counts',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final exerciseCounts = _countSavedStrengthExercises(strengthSessions);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSimpleSummaryCard(
                title: 'Strength Training Summary',
                totalExercises: exerciseCounts.length,
              ),
              const SizedBox(height: 16),
              _buildExerciseCountList(exerciseCounts),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTechnicalHistoryTab() {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};
        final technicalSessions = data['technicalSessions'] ?? [];

        if (technicalSessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 64,
                  color:
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Technical Performance Records',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Save some technical training sessions to see counts',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final skillCounts = _countSavedTechnicalSkills(technicalSessions);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSimpleSummaryCard(
                title: 'Technical Training Summary',
                totalExercises: skillCounts.length,
              ),
              const SizedBox(height: 16),
              _buildExerciseCountList(skillCounts),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _countSavedStrengthExercises(List<Map<String, dynamic>> sessions) {
    final counts = <String, int>{};

    for (final session in sessions) {
      final entries = (session['entries'] as List<dynamic>?) ?? [];
      for (final rawEntry in entries) {
        if (rawEntry is! Map<String, dynamic>) continue;
        final trainingEntry = TrainingEntry.fromJson(rawEntry);
        final exerciseNames = _getUniqueExerciseNames(trainingEntry);
        for (final name in exerciseNames) {
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }

    return counts;
  }

  Map<String, int> _countSavedTechnicalSkills(List<Map<String, dynamic>> sessions) {
    final counts = <String, int>{};

    for (final session in sessions) {
      final skillLabel = session['skillLabel'] as String? ?? session['name'] as String? ?? '';
      final normalized = skillLabel.trim();
      if (normalized.isEmpty) continue;
      counts[normalized] = (counts[normalized] ?? 0) + 1;
    }

    return counts;
  }


  Widget _buildSimpleSummaryCard({
    required String title,
    required int totalExercises,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryTile(
              label: 'Exercises Recorded',
              value: '$totalExercises',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCountList(Map<String, int> exerciseCounts) {
    final sortedEntries = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                '${entry.value} ${entry.value == 1 ? 'time' : 'times'}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Set<String> _getUniqueExerciseNames(TrainingEntry entry) {
    final names = <String>{};
    for (final key in entry.customStats.keys) {
      final normalized = _normalizeExerciseName(key, entry.customStats[key]);
      if (normalized.isNotEmpty) {
        names.add(normalized);
      }
    }
    return names;
  }

  String _normalizeExerciseName(String key, dynamic value) {
    // Prefer explicit name fields when customStats stores structured data
    if (value is Map) {
      if (value['name'] is String && (value['name'] as String).isNotEmpty) {
        return (value['name'] as String).trim();
      }
      if (value['exercise'] is String && (value['exercise'] as String).isNotEmpty) {
        return (value['exercise'] as String).trim();
      }
    }

    // Otherwise, normalize the key by removing common suffixes/details
    var name = key;

    // Remove well-known technical suffixes used for metrics
    name = name.replaceAll(RegExp(r'_(?:successful|neutral|fail|currentScore|targetScore|totalReps|totalReps|score|attempts|distance|duration)', caseSensitive: false), '');

    // Remove set identifiers and side prefixes
    name = name.replaceAll(RegExp(r'_(?:left|right)?_set\d+\b', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'_(?:set|sets|rep|reps|round|rounds|phase|stage)\d+\b', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'_(?:left|right)\b', caseSensitive: false), '');

    // Split on separators and remove trailing detail segments like set1, rep2, or raw counts
    final segments = name.split(RegExp(r'[_\-\s]+')).toList();
    while (segments.length > 1 && _isDetailSegment(segments.last)) {
      segments.removeLast();
    }
    name = segments.join(' ');

    // Remove inline patterns like "3x10" and any trailing detail-only markers
    name = name.replaceAll(RegExp(r"\d+x\d+(?:\s*reps?)?", caseSensitive: false), '').trim();
    name = name.replaceAll(RegExp(r"(?:\s|_)(?:set|sets|rep|reps|round|rounds|phase|stage)?\d+\s*$", caseSensitive: false), '').trim();

    // Cut at common separators that often precede sets/reps or details
    final separators = [':', '(', '|', '/', '\\'];
    for (final sep in separators) {
      final idx = name.indexOf(sep);
      if (idx > 0) {
        name = name.substring(0, idx);
        break;
      }
    }

    // Collapse multiple spaces
    name = name.replaceAll(RegExp(r"\s+"), ' ').trim();

    return name;
  }

  bool _isDetailSegment(String segment) {
    final normalized = segment.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.isEmpty) return false;
    if (RegExp(r'^(?:set|sets|rep|reps|round|rounds|phase|stage)$').hasMatch(normalized)) {
      return true;
    }
    if (RegExp(r'^(?:set|sets|rep|reps|round|rounds|phase|stage)?\d+$').hasMatch(normalized)) {
      return true;
    }
    if (RegExp(r'^\d+x\d+$').hasMatch(normalized)) {
      return true;
    }
    return false;
  }
}
